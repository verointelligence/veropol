import { failure, guard, json, limits, requireUser } from '@/lib/auth/instance';
import { readJson } from '@/lib/auth/http';

export const dynamic = 'force-dynamic';

export async function POST(request) {
    const blocked = await guard(request, limits.emailChange);
    if (blocked) return blocked;
    const session = await requireUser(request);
    if (session.response) return session.response;
    const body = await readJson(request);
    if (!body) return json({ ok: false, reason: 'bad_request' }, 400);
    const result = await session.auth.requestEmailChange({ user: session.user, newEmail: body.email });
    return result.ok ? json({ ok: true }) : failure(result);
}
