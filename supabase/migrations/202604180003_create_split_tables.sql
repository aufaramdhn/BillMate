-- Create split_groups table
CREATE TABLE public.split_groups (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Create split_members table
CREATE TABLE public.split_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  group_id UUID NOT NULL REFERENCES public.split_groups(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  name TEXT NOT NULL,
  email TEXT,
  share_percentage DECIMAL(5, 2) NOT NULL,
  is_paid BOOLEAN DEFAULT FALSE,
  paid_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  
  CONSTRAINT valid_share CHECK (share_percentage > 0 AND share_percentage <= 100)
);

-- Create split_bills table (junction table linking bills to groups)
CREATE TABLE public.split_bills (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  group_id UUID NOT NULL REFERENCES public.split_groups(id) ON DELETE CASCADE,
  bill_id UUID NOT NULL REFERENCES public.bills(id) ON DELETE CASCADE,
  payer_user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE RESTRICT,
  total_amount DECIMAL(12, 2) NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  
  UNIQUE(group_id, bill_id),
  CONSTRAINT valid_amount CHECK (total_amount > 0)
);

-- Create split_payments table (tracks payments between members)
CREATE TABLE public.split_payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  bill_id UUID NOT NULL REFERENCES public.split_bills(id) ON DELETE CASCADE,
  member_id UUID NOT NULL REFERENCES public.split_members(id) ON DELETE CASCADE,
  amount_owed DECIMAL(12, 2) NOT NULL,
  amount_paid DECIMAL(12, 2) DEFAULT 0,
  status TEXT DEFAULT 'unpaid' CHECK (status IN ('unpaid', 'partial', 'paid')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  
  CONSTRAINT valid_amounts CHECK (amount_paid >= 0 AND amount_paid <= amount_owed)
);

-- Enable RLS
ALTER TABLE public.split_groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.split_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.split_bills ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.split_payments ENABLE ROW LEVEL SECURITY;

-- RLS Policies for split_groups
CREATE POLICY "Users can view their own split groups"
  ON public.split_groups
  FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create split groups"
  ON public.split_groups
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own split groups"
  ON public.split_groups
  FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own split groups"
  ON public.split_groups
  FOR DELETE
  USING (auth.uid() = user_id);

-- RLS Policies for split_members
CREATE POLICY "Users can view members of their groups"
  ON public.split_members
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.split_groups
      WHERE split_groups.id = split_members.group_id
      AND split_groups.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can add members to their groups"
  ON public.split_members
  FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.split_groups
      WHERE split_groups.id = split_members.group_id
      AND split_groups.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can update members in their groups"
  ON public.split_members
  FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM public.split_groups
      WHERE split_groups.id = split_members.group_id
      AND split_groups.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can delete members from their groups"
  ON public.split_members
  FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM public.split_groups
      WHERE split_groups.id = split_members.group_id
      AND split_groups.user_id = auth.uid()
    )
  );

-- RLS Policies for split_bills
CREATE POLICY "Users can view split bills in their groups"
  ON public.split_bills
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.split_groups
      WHERE split_groups.id = split_bills.group_id
      AND split_groups.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can create split bills in their groups"
  ON public.split_bills
  FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.split_groups
      WHERE split_groups.id = split_bills.group_id
      AND split_groups.user_id = auth.uid()
    )
  );

-- RLS Policies for split_payments
CREATE POLICY "Users can view split payments in their groups"
  ON public.split_payments
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.split_bills
      INNER JOIN public.split_groups ON split_bills.group_id = split_groups.id
      WHERE split_bills.id = split_payments.bill_id
      AND split_groups.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can update split payments in their groups"
  ON public.split_payments
  FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM public.split_bills
      INNER JOIN public.split_groups ON split_bills.group_id = split_groups.id
      WHERE split_bills.id = split_payments.bill_id
      AND split_groups.user_id = auth.uid()
    )
  );

-- Create indexes for better query performance
CREATE INDEX idx_split_groups_user_id ON public.split_groups(user_id);
CREATE INDEX idx_split_members_group_id ON public.split_members(group_id);
CREATE INDEX idx_split_bills_group_id ON public.split_bills(group_id);
CREATE INDEX idx_split_bills_bill_id ON public.split_bills(bill_id);
CREATE INDEX idx_split_payments_bill_id ON public.split_payments(bill_id);
CREATE INDEX idx_split_payments_member_id ON public.split_payments(member_id);
