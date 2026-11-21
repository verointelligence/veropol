import { failure, getAuth, guard, json, limits } from '@/lib/auth/instance';
import { readJson } from '@/lib/auth/http';

export const dynamic = 'force-dynamic';

export async function POST(request) {
    const blocked = await guard(request, limits.code);
    if (blocked) return blocked;
    const body = await readJson(request);
    if (!body) return json({ ok: false, reason: 'bad_request' }, 400);
    const result = await getAuth().requestCode({ email: body.email });
    return result.ok ? json({ ok: true }) : failure(result);
}
