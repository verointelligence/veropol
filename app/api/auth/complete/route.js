import { failure, getAuth, guard, json, limits, sessionCookies, shapeSelf } from '@/lib/auth/instance';
import { readJson } from '@/lib/auth/http';

export const dynamic = 'force-dynamic';

export async function POST(request) {
    const blocked = await guard(request, limits.complete);
    if (blocked) return blocked;
    const body = await readJson(request);
    if (!body) return json({ ok: false, reason: 'bad_request' }, 400);
    const result = await getAuth().completeSignup({ ticket: body.ticket, username: body.username, birthDate: body.birthDate, deviceJwk: body.deviceJwk });
    if (!result.ok) return failure(result);
    return json({ ok: true, status: 'signed_in', user: shapeSelf(result.user) }, 201, sessionCookies(result.token));
}
