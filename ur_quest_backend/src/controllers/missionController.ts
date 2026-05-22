import { Request, Response } from "express";
import prisma from "../lib/prisma.ts";

/**
 * POST /api/missions/complete
 * Body: { userId, missionId, elapsedSeconds }
 */
export async function completeMission(req: Request, res: Response) {
  const { userId, missionId, elapsedSeconds } = req.body;

  if (!userId || !missionId || elapsedSeconds === undefined) {
    return res.status(400).json({ error: "userId, missionId y elapsedSeconds son requeridos." });
  }

  try {
    // 1. Cargar misión y usuario en paralelo
    const [mission, user] = await Promise.all([
      prisma.mission.findUnique({ where: { id: missionId } }),
      prisma.user.findUnique({ where: { id: userId } }),
    ]);

    if (!mission) return res.status(404).json({ error: "Misión no encontrada." });
    if (!user)   return res.status(404).json({ error: "Usuario no encontrado." });
    if (!mission.isActive) return res.status(400).json({ error: "La misión no está activa." });

    // 2. Anti-Cheat: tiempo mínimo requerido
    const minSeconds = mission.minDurationMin * 60;
    if (elapsedSeconds < minSeconds) {
      return res.status(400).json({
        error: "FRAUD_DETECTED",
        message: "¿Intentas engañar al Sistema o te estás engañando a ti mismo?",
        required: minSeconds,
        provided: elapsedSeconds,
      });
    }

    // 3. Cálculo de XP con bonus de racha
    //    XP_Final = xpReward * (1 + (currentStreak / 10))
    const xpFinal = Math.floor(mission.xpReward * (1 + user.currentStreak / 10));
    const newXpTotal = user.xpTotal + xpFinal;
    const newGrit    = user.gritBalance + mission.gritReward;

    // 4. Recalcular nivel: Nivel = floor(sqrt(xpTotal / 100))
    const newLevel = Math.max(1, Math.floor(Math.sqrt(newXpTotal / 100)));

    // 5. Actualizar streak (suponemos que se llama una vez al día; simplificado)
    const newStreak = user.currentStreak + 1;

    // 6. Transacción: actualizar user + crear MissionLog
    const [updatedUser, missionLog] = await prisma.$transaction([
      prisma.user.update({
        where: { id: userId },
        data: {
          xpTotal:      newXpTotal,
          gritBalance:  newGrit,
          level:        newLevel,
          currentStreak: newStreak,
          lastActiveAt: new Date(),
        },
        select: {
          id: true, username: true, level: true,
          gritBalance: true, xpTotal: true,
          currentStreak: true, hp: true,
        },
      }),
      prisma.missionLog.create({
        data: {
          userId,
          missionId,
          status:        "COMPLETED",
          completedAt:   new Date(),
          elapsedSeconds,
          gritApplied:   mission.gritReward,
          xpApplied:     xpFinal,
          hpApplied:     0,
        },
      }),
    ]);

    return res.status(200).json({
      message: `Felicidades. Has canjeado tu esfuerzo. +${xpFinal} XP / +${mission.gritReward} Grit.`,
      user: updatedUser,
      missionLog,
      levelUp: newLevel > user.level
        ? { levelUp: true, newLevel }
        : { levelUp: false },
    });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: "Error interno del servidor." });
  }
}
