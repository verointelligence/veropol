import { clearCookies, guard, json, limits, requireUser } from '@/lib/auth/instance';

export const dynamic = 'force-dynamic';

export async function POST(request) {
    const blocked = await guard(request, limits.mutate);
    if (blocked) return blocked;
    const session = await requireUser(request);
    if (session.response) return session.response;
    await session.auth.logout({ session: session.session });
    return json({ ok: true }, 200, clearCookies());
}
