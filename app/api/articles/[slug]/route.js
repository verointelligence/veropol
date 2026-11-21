import { adminSet, failure, guard, json, limits, requireUser } from '@/lib/auth/instance';
import { readJson } from '@/lib/auth/http';
import { deleteArticle, updateArticle } from '@/lib/articles';

export const dynamic = 'force-dynamic';

export async function PATCH(request, { params }) {
    const { slug } = await params;
    const blocked = await guard(request, limits.mutate);
    if (blocked) return blocked;
    const session = await requireUser(request);
    if (session.response) return session.response;
    const body = await readJson(request, 40000);
    if (!body) return json({ ok: false, reason: 'bad_request' }, 400);
    const result = await updateArticle(slug, session.user, body, adminSet().has(session.user.email));
    return result.ok ? json({ ok: true, slug: result.slug }) : failure(result);
}

export async function DELETE(request, { params }) {
    const { slug } = await params;
    const blocked = await guard(request, limits.mutate);
    if (blocked) return blocked;
    const session = await requireUser(request);
    if (session.response) return session.response;
    const result = await deleteArticle(slug, session.user, adminSet().has(session.user.email));
    return result.ok ? json({ ok: true }) : failure(result);
}
