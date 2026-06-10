-- AlterTable
ALTER TABLE "Mission" ADD COLUMN     "dueDate" TIMESTAMP(3),
ADD COLUMN     "isDaily" BOOLEAN NOT NULL DEFAULT true;
