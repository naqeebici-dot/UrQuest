import { Request, Response } from "express";
import prisma from "../lib/prisma.ts";

const CORRUPTION_GOLD_PENALTY   = 10;
const CORRUPTION_LOCK_THRESHOLD = 80;

/**
 * POST /api/rewards/buy
 * Body: { userId, rewardId }
 */
export async function buyReward(req: Request, res: Response) {
  const { userId, rewardId } = req.body;

  if (!userId || !rewardId) {
    return res.status(400).json({ error: "userId y rewardId son requeridos." });
  }

  try {
    const [user, reward] = await Promise.all([
      prisma.user.findUnique({ where: { id: userId } }),
      prisma.reward.findUnique({ where: { id: rewardId } }),
    ]);

    if (!user)   return res.status(404).json({ error: "Usuario no encontrado." });
    if (!reward) return res.status(404).json({ error: "Recompensa no encontrada." });
    if (!reward.isActive) return res.status(400).json({ error: "Recompensa no disponible." });

    // 1. Verificar Grit suficiente
    if (user.gritBalance < reward.currentCost) {
      return res.status(400).json({
        error: "INSUFFICIENT_GRIT",
        message: "No tienes suficiente Grit para esta recompensa.",
        required: reward.currentCost,
        current:  user.gritBalance,
        missing:  reward.currentCost - user.gritBalance,
      });
    }

    // 2. Calcular corrupción
    const isCorruptingTier = reward.tier === "GOLD" || reward.tier === "CUSTOM";
    const newCorruption = isCorruptingTier
      ? Math.min(100, user.corruptionScore + CORRUPTION_GOLD_PENALTY)
      : user.corruptionScore;

    // 3. Calcular nueva inflación del reward
    //    currentCost = baseCost * (1 + inflationRate) ^ weeklyPurchases+1
    const newWeeklyPurchases = reward.weeklyPurchases + 1;
    const newCurrentCost = Math.ceil(
      reward.baseCost * Math.pow(1 + reward.inflationRate, newWeeklyPurchases)
    );

    // 4. Transacción: actualizar user + reward + crear Purchase
    const [updatedUser, , purchase] = await prisma.$transaction([
      prisma.user.update({
        where: { id: userId },
        data: {
          gritBalance:    user.gritBalance - reward.currentCost,
          corruptionScore: newCorruption,
        },
        select: {
          id: true, username: true,
          gritBalance: true, corruptionScore: true,
        },
      }),
      prisma.reward.update({
        where: { id: rewardId },
        data: {
          weeklyPurchases: newWeeklyPurchases,
          currentCost:     newCurrentCost,
        },
      }),
      prisma.purchase.create({
        data: { userId, rewardId, gritSpent: reward.currentCost },
      }),
    ]);

    const response = {
      message: "Felicidades. Has canjeado tu esfuerzo por gratificación. Disfruta con responsabilidad.",
      gritSpent:   reward.currentCost,
      user:        updatedUser,
      purchase,
      nextRewardCost: newCurrentCost,
    };

    // 5. Advertencia de corrupción
    if (newCorruption >= CORRUPTION_LOCK_THRESHOLD) {
      response.corruptionWarning = {
        level: newCorruption,
        message:
          "[SISTEMA]: Tu índice de Corrupción ha alcanzado el umbral crítico. " +
          "Completa misiones de ESP para purificar el sistema o perderás el progreso.",
        locked: newCorruption >= 100,
      };
    }

    return res.status(200).json(response);
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: "Error interno del servidor." });
  }
}
