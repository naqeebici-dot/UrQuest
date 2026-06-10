import { Router } from "express";
import { getMarket, buyFromMarket } from "../controllers/marketController.ts";

const router = Router();

router.get("/",    getMarket);
router.post("/buy", buyFromMarket);

export default router;

