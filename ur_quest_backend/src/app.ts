import "dotenv/config";
import express from "express";
import cors from "cors";

import userRoutes    from "./routes/users.js";
import missionRoutes from "./routes/missions.js";
import rewardRoutes  from "./routes/rewards.js";
import marketRoutes  from "./routes/market.js";

const app  = express();
const PORT = process.env.PORT || 3000;

// ── Middleware ──────────────────────────────────────────────
app.use(cors());
app.use(express.json());

// ── Rutas ───────────────────────────────────────────────────
app.use("/api/users",    userRoutes);
app.use("/api/missions", missionRoutes);
app.use("/api/rewards",  rewardRoutes);
app.use("/api/market",   marketRoutes);

// ── Health check ────────────────────────────────────────────
app.get("/", (_req, res) => {
  res.json({ status: "ok", message: "[SISTEMA]: UrQuest Backend activo." });
});

// ── Error handler global ────────────────────────────────────
app.use((err, _req, res, _next) => {
  console.error(err);
  res.status(500).json({ error: "Error interno del servidor." });
});

// ── Arranque ────────────────────────────────────────────────
app.listen(PORT, () => {
  console.log(`[SISTEMA]: Servidor UrQuest escuchando en http://localhost:${PORT}`);
});

export default app;

