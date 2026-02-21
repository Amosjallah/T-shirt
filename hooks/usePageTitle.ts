'use client';

import { useEffect } from 'react';

const SITE_NAME = 'BEADEDLUX';

export function usePageTitle(title: string) {
  useEffect(() => {
    document.title = title ? `${title} | ${SITE_NAME}` : `${SITE_NAME} | quality designer ladies bags, handbags & accessories`;
  }, [title]);
}
