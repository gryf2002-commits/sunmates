/* SunMates — configuration Tailwind (CDN Play).
   Les tokens viennent EXACTEMENT de l'app (index.html / DESIGN_SYSTEM.md).
   Chargé APRÈS https://cdn.tailwindcss.com sur chaque page. */
tailwind.config = {
  theme: {
    extend: {
      colors: {
        bg:    '#FFF4E6',   // fond crème chaud
        card:  '#FFFFFF',
        cream: '#FFF1E0',
        paper: '#FFFDF8',
        coral: { DEFAULT: '#FF5A4D', ink: '#C23A2D', soft: '#FFE6DC' }, // ink = texte AA sur clair
        mango: '#FF8A3D',
        amber: '#FFC93C',
        teal:  { DEFAULT: '#14C2B8', deep: '#0E9E96' },
        grape: '#B25CC9',
        ink:   { DEFAULT: '#39203A', warm: '#44264A' }, // encre prune
        body:  '#5B4455',
        muted: '#7F6878',
        line:  '#F6E3D6',
        gold:  '#FFB52E',
        night: { DEFAULT: '#190E2E', card: '#271641' },
      },
      fontFamily: {
        sans:    ['Manrope', 'system-ui', '-apple-system', 'Segoe UI', 'sans-serif'],
        display: ['Fraunces', 'Georgia', 'serif'],
      },
      borderRadius: { sm: '14px', DEFAULT: '22px', lg: '28px', xl: '32px', '2xl': '40px' },
      boxShadow: {
        warm:      '0 16px 38px rgba(45,38,52,.10), 0 3px 10px rgba(40,25,35,.05)',
        'warm-sm': '0 8px 18px rgba(45,38,52,.08)',
        pop:       '0 22px 50px rgba(40,34,46,.22)',
        glow:      '0 14px 34px rgba(255,90,77,.30)',
        ring:      '0 0 0 4px rgba(255,90,77,.16)',
      },
      backgroundImage: {
        sunset:        'linear-gradient(135deg, #FFC93C 0%, #FF7A3D 20%, #FF4F6D 52%)',
        'sunset-full': 'linear-gradient(150deg, #FFC93C 0%, #FF7A3D 38%, #FF4F6D 72%, #B25CC9 100%)',
        day:           'radial-gradient(125% 90% at 50% -10%, #FFE9C4 0%, #FFD3A6 45%, #FFC0A0 100%)',
        night:         'radial-gradient(130% 80% at 50% -8%, #3b2550 0%, #2a1c3e 34%, #20182f 64%, #171026 100%)',
      },
      maxWidth: { content: '1140px' },
      letterSpacing: { tightish: '-0.02em' },
    },
  },
};
