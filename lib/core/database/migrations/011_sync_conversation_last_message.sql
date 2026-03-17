-- Keep conversation summary fields in sync when new messages arrive.
CREATE OR REPLACE FUNCTION sync_conversation_last_message()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  UPDATE conversations
  SET
    last_message_at = NEW.created_at,
    last_message_preview = LEFT(NEW.body, 200)
  WHERE id = NEW.conversation_id;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_sync_conversation_last_message ON messages;

CREATE TRIGGER trg_sync_conversation_last_message
AFTER INSERT ON messages
FOR EACH ROW
EXECUTE FUNCTION sync_conversation_last_message();
