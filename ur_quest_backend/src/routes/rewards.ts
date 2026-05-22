import { Router } from "express";
import { buyReward } from "../controllers/rewardController.ts";

const router = Router();
router.post("/buy", buyReward);
export default router;
