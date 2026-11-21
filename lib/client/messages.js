const TEXT = {
    domain_not_allowed: 'Use a Gmail, Outlook, Proton, iCloud or Yahoo address.',
    email_format: 'Enter a valid email address.',
    cooldown: 'Please wait a moment before trying again.',
    hourly_limit: 'Too many codes requested. Try again later.',
    mail_failed: 'We could not send the email. Try again shortly.',
    invalid: 'That code is not correct.',
    expired: 'That code has expired. Request a new one.',
    locked: 'Too many attempts. Request a new code.',
    none: 'Request a new code first.',
    device_key: 'This browser could not create a secure key. Update it and try again.',
    banned: 'This account is suspended.',
    ticket: 'Your sign-up session expired. Start again.',
    username_format: 'Use 3 to 20 letters, numbers or underscores, with at least one letter.',
    username_reserved: 'That username is not available.',
    username_taken: 'That username is taken.',
    birth_format: 'Enter a valid date of birth.',
    too_young: 'You must be at least 13 to use VERO.',
    display_name: 'Name must be 1 to 40 characters.',
    bio: 'Bio must be 280 characters or fewer.',
    same_email: 'That is already your email.',
    email_taken: 'That email belongs to another account.',
    rate_limited: 'Too many requests. Slow down and try again.',
    unavailable: 'The service is temporarily unavailable.',
    forbidden: 'Request blocked. Reload the page and try again.',
    unauthorized: 'Your session ended. Sign in again.',
    title: 'The title must be 12 to 140 characters.',
    summary: 'The summary must be 40 to 300 characters.',
    body: 'The article must be 400 to 30,000 characters.',
    category: 'Choose a category.',
    links: 'Remove links from the title and summary, and keep at most 3 in the text.',
    spam: 'The text looks repetitive. Please rewrite it.',
    daily_limit: 'You reached the limit of 5 articles in 24 hours.',
    duplicate: 'You already published an article with this title today.',
    adult_only: 'Publishing is limited to users aged 18 or older.',
    not_found: 'That article no longer exists.',
    bad_request: 'The request was not understood.'
};

export function messageFor(data) {
    if (!data || !data.reason) return 'Something went wrong. Try again.';
    if (data.reason === 'cooldown' && data.retryAt) return 'You can change your username again on ' + new Date(data.retryAt).toLocaleDateString('en-US', { month: 'long', day: 'numeric', year: 'numeric' }) + '.';
    if (data.reason === 'invalid' && typeof data.attemptsLeft === 'number') return 'That code is not correct. ' + data.attemptsLeft + ' attempts left.';
    return TEXT[data.reason] || 'Something went wrong. Try again.';
}
