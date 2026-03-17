-- Auto-create a conversation and first message when an inquiry is submitted.
CREATE OR REPLACE FUNCTION create_conversation_from_inquiry()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_landlord_id UUID;
  v_conversation_id UUID;
BEGIN
  SELECT landlord_id
  INTO v_landlord_id
  FROM properties
  WHERE id = NEW.property_id;

  IF v_landlord_id IS NULL THEN
    RETURN NEW;
  END IF;

  INSERT INTO conversations (
    inquiry_id,
    property_id,
    tenant_id,
    landlord_id,
    last_message_at,
    last_message_preview
  )
  VALUES (
    NEW.id,
    NEW.property_id,
    NEW.user_id,
    v_landlord_id,
    NOW(),
    LEFT(NEW.message, 200)
  )
  ON CONFLICT (inquiry_id)
  DO UPDATE SET
    last_message_at = EXCLUDED.last_message_at,
    last_message_preview = EXCLUDED.last_message_preview
  RETURNING id INTO v_conversation_id;

  IF v_conversation_id IS NULL THEN
    SELECT id
    INTO v_conversation_id
    FROM conversations
    WHERE inquiry_id = NEW.id;
  END IF;

  INSERT INTO messages (conversation_id, sender_id, body)
  VALUES (v_conversation_id, NEW.user_id, NEW.message);

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_create_conversation_from_inquiry ON inquiries;

CREATE TRIGGER trg_create_conversation_from_inquiry
AFTER INSERT ON inquiries
FOR EACH ROW
EXECUTE FUNCTION create_conversation_from_inquiry();
