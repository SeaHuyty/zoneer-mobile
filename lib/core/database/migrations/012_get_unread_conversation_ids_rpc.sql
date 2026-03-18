-- Return distinct unread conversation ids for the current authenticated user.
CREATE OR REPLACE FUNCTION get_unread_conversation_ids(p_user_id UUID)
RETURNS TABLE(conversation_id UUID)
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = public
AS $$
BEGIN
  IF auth.uid() IS NULL OR auth.uid() <> p_user_id THEN
    RETURN;
  END IF;

  RETURN QUERY
  SELECT DISTINCT m.conversation_id
  FROM messages m
  INNER JOIN conversations c ON c.id = m.conversation_id
  WHERE (c.tenant_id = p_user_id OR c.landlord_id = p_user_id)
    AND m.sender_id <> p_user_id
    AND m.read_at IS NULL;
END;
$$;
