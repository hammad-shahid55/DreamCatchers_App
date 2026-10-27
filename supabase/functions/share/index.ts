const APP_SCHEME = "com.dreamcatchers.app";
const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

Deno.serve((req) => {
  const postId = new URL(req.url).searchParams.get("post") ?? "";
  if (!UUID.test(postId)) {
    return new Response("Invalid post link", { status: 400 });
  }
  return new Response(null, {
    status: 302,
    headers: {
      Location: `${APP_SCHEME}://post/${postId}`,
      "Cache-Control": "no-store",
    },
  });
});
