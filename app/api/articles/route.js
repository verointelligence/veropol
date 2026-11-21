import { failure, guard, json, limits, requireUser, shapeSelf } from '@/lib/auth/instance';
import { readJson } from '@/lib/auth/http';
import { createArticle } from '@/lib/articles';

export const dynamic = 'force-dynamic';

export async function POST(request) {
    const blocked = await guard(request, limits.mutate);
    if (blocked) return blocked;
    const session = await requireUser(request);
    if (session.response) return session.response;
    if (!shapeSelf(session.user).isAdult) return json({ ok: false, reason: 'adult_only' }, 403);
    const body = await readJson(request, 40000);
    if (!body) return json({ ok: false, reason: 'bad_request' }, 400);
    const result = await createArticle(session.user, body);
    return result.ok ? json({ ok: true, slug: result.slug }, 201) : failure(result);
}
