---
mode: agent
description: Create a new Supabase SQL migration for Dukaan AI
---

# New Supabase Migration

## Step 1 — Check Before Creating
Before writing, confirm:
- Does this table already exist in `supabase/migrations/`?
- Does this column already exist in the table definition?
- Is there an existing migration that partially covers this change?

State your findings. If the table/column exists, STOP and say so instead of creating duplicates.

## Step 2 — Create Migration File
File: `supabase/migrations/${input:timestamp}_${input:migrationName}.sql`
(timestamp format: YYYYMMDDHHMMSS, e.g., 20260401120000)

Template:
```sql
-- Migration: ${input:migrationName}
-- Created: ${input:timestamp}
-- Description: ${input:description}

-- ============================================================
-- UP
-- ============================================================

-- Table creation (always use IF NOT EXISTS)
CREATE TABLE IF NOT EXISTS public.${input:tableName} (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  -- add columns here
  created_at timestamptz DEFAULT now() NOT NULL,
  updated_at timestamptz DEFAULT now() NOT NULL
);

-- Indexes (always index user_id and created_at)
CREATE INDEX IF NOT EXISTS idx_${input:tableName}_user_id ON public.${input:tableName}(user_id);
CREATE INDEX IF NOT EXISTS idx_${input:tableName}_created_at ON public.${input:tableName}(created_at DESC);

-- RLS
ALTER TABLE public.${input:tableName} ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own rows" ON public.${input:tableName}
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own rows" ON public.${input:tableName}
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own rows" ON public.${input:tableName}
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own rows" ON public.${input:tableName}
  FOR DELETE USING (auth.uid() = user_id);

-- Auto-update updated_at trigger
CREATE OR REPLACE TRIGGER handle_updated_at
  BEFORE UPDATE ON public.${input:tableName}
  FOR EACH ROW EXECUTE FUNCTION moddatetime(updated_at);

-- ============================================================
-- DOWN (Rollback)
-- ============================================================
-- DROP TABLE IF EXISTS public.${input:tableName};
```

## Step 3 — Update Domain Model
After migration, update or create the corresponding Dart model in:
`lib/features/<feature>/domain/<ModelName>.dart`
Ensure all column names match exactly — no assumptions.
