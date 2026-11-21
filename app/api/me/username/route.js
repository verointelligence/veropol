import { failure, guard, json, limits, requireUser, shapeSelf } from '@/lib/auth/instance';
import { readJson } from '@/lib/auth/http';

export const dynamic = 'force-dynamic';

export async function POST(request) {
    const blocked = await guard(request, limits.mutate);
    if (blocked) return blocked;
    const session = await requireUser(request);
    if (session.response) return session.response;
    const body = await readJson(request);
    if (!body) return json({ ok: false, reason: 'bad_request' }, 400);
    const result = await session.auth.changeUsername({ user: session.user, username: body.username });
    if (result.ok) return json({ ok: true, user: shapeSelf(result.user) });
    if (result.reason === 'cooldown') return json({ ok: false, reason: 'cooldown', retryAt: result.retryAt }, 429);
    return failure(result);
}
