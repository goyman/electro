// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

const plugin = require('tailwindcss/plugin')
const { Hsluv } = require('hsluv')

const hsluv = new Hsluv()

function hsluvaToRgba (h, s, l, a) {
    if (a === undefined) {
        a = 1
    }

    hsluv.hsluv_h = h
    hsluv.hsluv_s = s
    hsluv.hsluv_l = l
    hsluv.hsluvToRgb()
    return 'rgba(' +
    (Math.round(255 * hsluv.rgb_r)) + ', ' +
    (Math.round(255 * hsluv.rgb_g)) + ', ' +
    (Math.round(255 * hsluv.rgb_b)) + ', ' +
    a + ')'
}

function genShades (h, s) {
    const res = {}
    hsluv.hsluv_h = h
    hsluv.hsluv_s = s
    for (let i = 1; i < 40; i++) {
        hsluv.hsluv_l = 102 - 2.5 * i
        hsluv.hsluvToHex()
        res[25 * i] = hsluv.hex
    }

    return res
}

module.exports = {
    content: [
        './js/**/*.js',
        '../lib/*_web.ex',
        '../lib/*_web/**/*.*ex'
    ],
    theme: {
        extend: {
            colors: { blue: genShades(250, 50) },
            spacing: {
                72: '18rem',
                84: '21rem',
                96: '24rem'
            },
            width: {
                128: '32rem',
                192: '48rem',
                256: '64rem'
            },
            maxWidth: { '2xs': '10rem' }
        }
    },
    plugins: [
        require('@tailwindcss/forms'),
        plugin(({ addVariant }) => addVariant(
            'phx-no-feedback',
            ['&.phx-no-feedback', '.phx-no-feedback &']
        )),
        plugin(({ addVariant }) => addVariant(
            'phx-click-loading',
            ['&.phx-click-loading', '.phx-click-loading &']
        )),
        plugin(({ addVariant }) => addVariant(
            'phx-submit-loading',
            ['&.phx-submit-loading', '.phx-submit-loading &']
        )),
        plugin(({ addVariant }) => addVariant(
            'phx-change-loading',
            ['&.phx-change-loading', '.phx-change-loading &']
        ))
    ]
}
