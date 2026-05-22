import { Router } from "express";
import { completeMission } from "../controllers/missionController.ts";

const router = Router();
router.post("/complete", completeMission);
export default router;
