CREATE TABLE IF NOT EXISTS conversations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  inquiry_id UUID NOT NULL UNIQUE,
  property_id UUID NOT NULL,
  tenant_id UUID NOT NULL,
  landlord_id UUID NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  last_message_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  last_message_preview TEXT,
  FOREIGN KEY (inquiry_id) REFERENCES inquiries(id) ON DELETE CASCADE,
  FOREIGN KEY (property_id) REFERENCES properties(id) ON DELETE CASCADE,
  FOREIGN KEY (tenant_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (landlord_id) REFERENCES users(id) ON DELETE CASCADE,
  CHECK (tenant_id <> landlord_id)
);

CREATE TABLE IF NOT EXISTS messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id UUID NOT NULL,
  sender_id UUID NOT NULL,
  body TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  read_at TIMESTAMP WITH TIME ZONE,
  FOREIGN KEY (conversation_id) REFERENCES conversations(id) ON DELETE CASCADE,
  FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_conversations_tenant_id ON conversations(tenant_id);
CREATE INDEX IF NOT EXISTS idx_conversations_landlord_id ON conversations(landlord_id);
CREATE INDEX IF NOT EXISTS idx_conversations_last_message_at ON conversations(last_message_at DESC);
CREATE INDEX IF NOT EXISTS idx_messages_conversation_created_at ON messages(conversation_id, created_at); 

-- Enable Row Level Security
ALTER TABLE conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

-- Conversation policies (only participants can access)
CREATE POLICY "Conversations are viewable by participants"
  ON conversations FOR SELECT
  USING (auth.uid() = tenant_id OR auth.uid() = landlord_id);

CREATE POLICY "Participants can update conversation summary"
  ON conversations FOR UPDATE
  USING (auth.uid() = tenant_id OR auth.uid() = landlord_id)
  WITH CHECK (auth.uid() = tenant_id OR auth.uid() = landlord_id);

-- Message policies (only participants can read/send messages)
CREATE POLICY "Messages are viewable by conversation participants"
  ON messages FOR SELECT
  USING (
    EXISTS (
      SELECT 1
      FROM conversations c
      WHERE c.id = messages.conversation_id
        AND (auth.uid() = c.tenant_id OR auth.uid() = c.landlord_id)
    )
  );

CREATE POLICY "Participants can send messages"
  ON messages FOR INSERT
  WITH CHECK (
    sender_id = auth.uid()
    AND EXISTS (
      SELECT 1
      FROM conversations c
      WHERE c.id = messages.conversation_id
        AND (auth.uid() = c.tenant_id OR auth.uid() = c.landlord_id)
    )
  );

CREATE POLICY "Participants can mark messages as read"
  ON messages FOR UPDATE
  USING (
    EXISTS (
      SELECT 1
      FROM conversations c
      WHERE c.id = messages.conversation_id
        AND (auth.uid() = c.tenant_id OR auth.uid() = c.landlord_id)
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1
      FROM conversations c
      WHERE c.id = messages.conversation_id
        AND (auth.uid() = c.tenant_id OR auth.uid() = c.landlord_id)
    )
  );