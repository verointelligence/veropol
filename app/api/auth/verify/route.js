import { failure, getAuth, guard, json, limits, sessionCookies, shapeSelf } from '@/lib/auth/instance';
import { readJson } from '@/lib/auth/http';

export const dynamic = 'force-dynamic';

export async function POST(request) {
    const blocked = await guard(request, limits.verify);
    if (blocked) return blocked;
    const body = await readJson(request);
    if (!body) return json({ ok: false, reason: 'bad_request' }, 400);
    const result = await getAuth().verifyCode({ email: body.email, code: body.code, deviceJwk: body.deviceJwk });
    if (!result.ok) return failure(result);
    if (result.status === 'profile_required') return json({ ok: true, status: 'profile_required', ticket: result.ticket });
    return json({ ok: true, status: 'signed_in', user: shapeSelf(result.user) }, 200, sessionCookies(result.token));
}
