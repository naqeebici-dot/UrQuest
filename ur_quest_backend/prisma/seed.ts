/**
 * Seed de UrQuest — ejecutar con: npm run seed
 * Pobla: Attributes (6 pilares) + Missions (12 diarias) + Rewards (4 vicios base)
 * Es idempotente: usa upsert para no duplicar en cada ejecución.
 */
import "dotenv/config";
import pg from "pg";
import { PrismaPg } from "@prisma/adapter-pg";
import { PrismaClient } from "../generated/prisma/client.ts";

const pool    = new pg.Pool({ connectionString: process.env.DATABASE_URL });
const adapter = new PrismaPg(pool);
const prisma  = new PrismaClient({ adapter });

// ── 1. ATRIBUTOS ─────────────────────────────────────────────────────────────
const ATTRIBUTES = [
  { type: "INT",  name: "Intelecto",      description: "Cursos, idiomas, aprendizaje continuo",        color: "#00B0FF", icon: "brain"   },
  { type: "LOG",  name: "Lógica",         description: "Estrategia, finanzas, pensamiento crítico",     color: "#00E676", icon: "chess"   },
  { type: "CREA", name: "Creatividad",    description: "Arte, diseño, escritura, música",               color: "#FF4081", icon: "palette" },
  { type: "ESP",  name: "Espiritualidad", description: "Meditación, bienestar mental, propósito",       color: "#AA00FF", icon: "lotus"   },
  { type: "VIT",  name: "Vitalidad",      description: "Ejercicio, nutrición, descanso, salud",         color: "#FF1744", icon: "heart"   },
  { type: "SOC",  name: "Social",         description: "Relaciones, comunidad, comunicación",           color: "#00E5FF", icon: "people"  },
] as const;

// ── 2. MISIONES DIARIAS (2 por atributo) ─────────────────────────────────────
const MISSIONS = [
  { title: "Entrenamiento de fuerza",   description: "30 minutos de pesas o calistenia",          rank: "B", attr: "VIT",  grit: 80,   xp: 60,  hp: 15, minDur: 25 },
  { title: "Correr 5 km",               description: "Sal a correr sin excusas",                   rank: "A", attr: "VIT",  grit: 120,  xp: 100, hp: 20, minDur: 20 },
  { title: "Leer 20 páginas",           description: "Lectura profunda, sin scroll en paralelo",   rank: "C", attr: "INT",  grit: 50,   xp: 40,  hp: 10, minDur: 20 },
  { title: "Estudiar idioma 20m",       description: "Duolingo, Anki o clase online",              rank: "C", attr: "INT",  grit: 50,   xp: 40,  hp: 10, minDur: 18 },
  { title: "Resolver reto de código",   description: "LeetCode, Codewars o proyecto propio",       rank: "B", attr: "LOG",  grit: 90,   xp: 70,  hp: 15, minDur: 30 },
  { title: "Partida de ajedrez",        description: "Análisis post-partida incluido",              rank: "C", attr: "LOG",  grit: 60,   xp: 45,  hp: 10, minDur: 20 },
  { title: "Meditación 10 minutos",     description: "Respiración consciente, sin distracciones",  rank: "C", attr: "ESP",  grit: 40,   xp: 35,  hp: 10, minDur: 10 },
  { title: "Diario de gratitud",        description: "3 cosas positivas del día, escrito a mano",  rank: "C", attr: "ESP",  grit: 30,   xp: 25,  hp: 5,  minDur: 5  },
  { title: "Practicar instrumento",     description: "20 minutos de práctica deliberada",           rank: "B", attr: "CREA", grit: 70,   xp: 55,  hp: 12, minDur: 18 },
  { title: "Dibujar un boceto",         description: "Sin juzgar el resultado, solo crear",         rank: "C", attr: "CREA", grit: 40,   xp: 35,  hp: 8,  minDur: 10 },
  { title: "Llamar a un familiar",      description: "Conexión humana real, no un mensaje",         rank: "C", attr: "SOC",  grit: 35,   xp: 30,  hp: 5,  minDur: 5  },
  { title: "Asistir a evento social",   description: "Meetup, quedada o evento comunitario",        rank: "A", attr: "SOC",  grit: 150,  xp: 120, hp: 20, minDur: 45 },
] as const;

// ── 3. REWARDS / VICIOS ───────────────────────────────────────────────────────
const REWARDS = [
  { name: "Cerveza / Refresco",         description: "Una bebida de recompensa. Mereces el placer.",              tier: "BRONZE", baseCost: 50,   inflationRate: 0.10 },
  { name: "Netflix 1 hora",             description: "Una hora de entretenimiento sin culpa. Bien ganada.",       tier: "BRONZE", baseCost: 80,   inflationRate: 0.10 },
  { name: "Salir de fiesta",            description: "Noche de libertad. El Sistema aprueba el descanso social.", tier: "SILVER", baseCost: 500,  inflationRate: 0.15 },
  { name: "Capricho Caro / Videojuego", description: "Compra grande. El Sistema advierte: úsalo con cabeza.",    tier: "GOLD",   baseCost: 2000, inflationRate: 0.20 },
] as const;

// ── MAIN ──────────────────────────────────────────────────────────────────────
async function main() {
  console.log("🌱 [SEED] Iniciando sembrado de datos base...\n");

  // 1. Attributes
  console.log("→ Attributes...");
  for (const attr of ATTRIBUTES) {
    await (prisma as any).attribute.upsert({
      where:  { type: attr.type },
      update: { name: attr.name, description: attr.description, color: attr.color, icon: attr.icon },
      create: { type: attr.type, name: attr.name, description: attr.description, color: attr.color, icon: attr.icon },
    });
  }
  console.log(`  ✅ ${ATTRIBUTES.length} atributos listos.`);

  // 2. Missions
  console.log("→ Missions...");
  for (const m of MISSIONS) {
    const attr = await (prisma as any).attribute.findUnique({ where: { type: m.attr } });
    if (!attr) { console.warn(`  ⚠️  Atributo ${m.attr} no encontrado — omitiendo "${m.title}"`); continue; }

    const existing = await (prisma as any).mission.findFirst({ where: { title: m.title } });
    if (existing) {
      await (prisma as any).mission.update({
        where: { id: existing.id },
        data:  { description: m.description, rank: m.rank, gritReward: m.grit, xpReward: m.xp, hpPenalty: m.hp, minDurationMin: m.minDur, attributeId: attr.id },
      });
    } else {
      await (prisma as any).mission.create({
        data: { title: m.title, description: m.description, rank: m.rank, type: "DAILY", gritReward: m.grit, xpReward: m.xp, hpPenalty: m.hp, gritPenalty: 5, minDurationMin: m.minDur, attributeId: attr.id },
      });
    }
  }
  console.log(`  ✅ ${MISSIONS.length} misiones listas.`);

  // 3. Rewards
  console.log("→ Rewards...");
  for (const r of REWARDS) {
    const existing = await (prisma as any).reward.findFirst({ where: { name: r.name } });
    if (existing) {
      await (prisma as any).reward.update({
        where: { id: existing.id },
        data:  { description: r.description, tier: r.tier, baseCost: r.baseCost, inflationRate: r.inflationRate },
      });
    } else {
      await (prisma as any).reward.create({
        data: { name: r.name, description: r.description, tier: r.tier, baseCost: r.baseCost, currentCost: r.baseCost, inflationRate: r.inflationRate },
      });
    }
  }
  console.log(`  ✅ ${REWARDS.length} rewards listos.`);

  console.log("\n🏆 [SEED] Completado. El Sistema está listo para recibir jugadores.");
}

main()
  .catch((e) => { console.error("❌ [SEED] Error:", e); process.exit(1); })
  .finally(async () => { await (prisma as any).$disconnect(); await pool.end(); });

