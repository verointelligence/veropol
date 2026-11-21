import { failure, guard, json, limits, requireUser, shapeSelf } from '@/lib/auth/instance';
import { readJson } from '@/lib/auth/http';

export const dynamic = 'force-dynamic';

export async function GET(request) {
    const session = await requireUser(request);
    if (session.response) return session.response;
    return json({ ok: true, user: shapeSelf(session.user) });
}

export async function PATCH(request) {
    const blocked = await guard(request, limits.mutate);
    if (blocked) return blocked;
    const session = await requireUser(request);
    if (session.response) return session.response;
    const body = await readJson(request);
    if (!body) return json({ ok: false, reason: 'bad_request' }, 400);
    const result = await session.auth.updateProfile({ user: session.user, displayName: body.displayName, bio: body.bio });
    return result.ok ? json({ ok: true, user: shapeSelf(result.user) }) : failure(result);
}
