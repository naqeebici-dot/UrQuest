import { Request, Response } from "express";
import prisma from "../lib/prisma.ts";

const CORRUPTION_GOLD_PENALTY   = 10;
const CORRUPTION_LOCK_THRESHOLD = 80;

/** currentCost = baseCost * (1 + weeklyPurchases * inflationRate), redondeado */
function calcCurrentCost(baseCost: number, weeklyPurchases: number, inflationRate: number): number {
  return Math.round(baseCost * (1 + weeklyPurchases * inflationRate));
}

// ── GET /api/market ───────────────────────────────────────────────────────────
export async function getMarket(_req: Request, res: Response) {
  try {
    const rewards = await (prisma as any).reward.findMany({
      where:   { isActive: true },
      orderBy: { baseCost: "asc" },
    });

    const market = rewards.map((r: any) => ({
      id:              r.id,
      name:            r.name,
      description:     r.description,
      tier:            r.tier,
      baseCost:        r.baseCost,
      currentCost:     calcCurrentCost(r.baseCost, r.weeklyPurchases, r.inflationRate),
      inflationRate:   r.inflationRate,
      weeklyPurchases: r.weeklyPurchases,
      isCustomSlot:    r.isCustomSlot,
    }));

    return res.json({ market });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: "Error interno del servidor." });
  }
}

// ── POST /api/market/buy ──────────────────────────────────────────────────────
export async function buyFromMarket(req: Request, res: Response) {
  const { userId, rewardId } = req.body;

  if (!userId || !rewardId) {
    return res.status(400).json({ error: "userId y rewardId son requeridos." });
  }

  try {
    const [user, reward] = await Promise.all([
      (prisma as any).user.findUnique({ where: { id: userId } }),
      (prisma as any).reward.findUnique({ where: { id: rewardId } }),
    ]);

    if (!user)            return res.status(404).json({ error: "Usuario no encontrado." });
    if (!reward)          return res.status(404).json({ error: "Recompensa no encontrada." });
    if (!reward.isActive) return res.status(400).json({ error: "Recompensa no disponible." });

    // 1. Precio actual con inflación
    const currentCost = calcCurrentCost(reward.baseCost, reward.weeklyPurchases, reward.inflationRate);

    // 2. Verificar Grit suficiente
    if (user.gritBalance < currentCost) {
      return res.status(400).json({
        error:    "INSUFFICIENT_AURA",
        message:  "No tienes suficiente AURA para esta recompensa.",
        required: currentCost,
        current:  user.gritBalance,
        missing:  currentCost - user.gritBalance,
      });
    }

    // 3. Corrupción (solo GOLD y CUSTOM)
    const isToxic       = reward.tier === "GOLD" || reward.tier === "CUSTOM";
    const newCorruption = isToxic
      ? Math.min(100, user.corruptionScore + CORRUPTION_GOLD_PENALTY)
      : user.corruptionScore;

    // 4. Precio siguiente tras esta compra
    const newWeeklyPurchases = reward.weeklyPurchases + 1;
    const nextCost = calcCurrentCost(reward.baseCost, newWeeklyPurchases, reward.inflationRate);

    // 5. Transacción atómica
    const [updatedUser, , purchase] = await (prisma as any).$transaction([
      (prisma as any).user.update({
        where:  { id: userId },
        data:   { gritBalance: user.gritBalance - currentCost, corruptionScore: newCorruption },
        select: { id: true, username: true, gritBalance: true, corruptionScore: true },
      }),
      (prisma as any).reward.update({
        where: { id: rewardId },
        data:  { weeklyPurchases: newWeeklyPurchases, currentCost: nextCost },
      }),
      (prisma as any).purchase.create({
        data: { userId, rewardId, gritSpent: currentCost },
      }),
    ]);

    const response: any = {
      message:        "Has canjeado tu esfuerzo. Disfruta con responsabilidad.",
      auraSpent:      currentCost,
      gritSpent:      currentCost, // Para compatibilidad
      user:           { ...updatedUser, auraBalance: updatedUser.gritBalance },
      purchase,
      nextRewardCost: nextCost,
    };

    // 6. Advertencia de corrupción crítica
    if (newCorruption >= CORRUPTION_LOCK_THRESHOLD) {
      response.warning = "Corrupción crítica";
      response.corruptionWarning = {
        level:   newCorruption,
        message: "[SISTEMA]: Índice de Corrupción en umbral crítico. Completa misiones de ESP para purificarte.",
        locked:  newCorruption >= 100,
      };
    }

    return res.status(200).json(response);
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: "Error interno del servidor." });
  }
}

