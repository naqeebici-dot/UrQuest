import bcrypt from "bcryptjs";
import prisma from "../lib/prisma.js";

/**
 * POST /api/users
 * Body: { username, email, password }
 */
export async function createUser(req, res) {
  const { username, email, password } = req.body;

  if (!username || !email || !password) {
    return res.status(400).json({ error: "username, email y password son requeridos." });
  }

  try {
    const passwordHash = await bcrypt.hash(password, 10);

    const user = await prisma.user.create({
      data: { username, email, passwordHash },
      select: {
        id: true,
        username: true,
        email: true,
        level: true,
        gritBalance: true,
        xpTotal: true,
        hp: true,
        corruptionScore: true,
        currentStreak: true,
        jobClass: true,
        createdAt: true,
      },
    });

    // Inicializar los 6 atributos del hexágono para el nuevo usuario
    const attributes = await prisma.attribute.findMany();
    if (attributes.length > 0) {
      await prisma.userAttribute.createMany({
        data: attributes.map((attr) => ({
          userId: user.id,
          attributeId: attr.id,
        })),
      });
    }

    // Alias auraBalance para compatibilidad con el nuevo nombre de la moneda
    return res.status(201).json({
      message: "Usuario creado.",
      user: { ...user, auraBalance: user.gritBalance },
    });
  } catch (err) {
    if (err.code === "P2002") {
      return res.status(409).json({ error: "El username o email ya existe." });
    }
    console.error(err);
    return res.status(500).json({ error: "Error interno del servidor." });
  }
}

