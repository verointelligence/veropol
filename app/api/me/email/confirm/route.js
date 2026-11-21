import { failure, guard, json, limits, requireUser, shapeSelf } from '@/lib/auth/instance';
import { readJson } from '@/lib/auth/http';

export const dynamic = 'force-dynamic';

export async function POST(request) {
    const blocked = await guard(request, limits.verify);
    if (blocked) return blocked;
    const session = await requireUser(request);
    if (session.response) return session.response;
    const body = await readJson(request);
    if (!body) return json({ ok: false, reason: 'bad_request' }, 400);
    const result = await session.auth.confirmEmailChange({ user: session.user, newEmail: body.email, code: body.code });
    return result.ok ? json({ ok: true, user: shapeSelf(result.user) }) : failure(result);
}
