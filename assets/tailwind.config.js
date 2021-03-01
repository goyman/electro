module.exports = {
  theme: {
    extend: {
      screens: {
        print: { raw: 'print' }
      },
      spacing: {
        128: '32rem',
        256: '64rem'
      },
      borderWidth: {
        12: '12px'
      }
    }
  },
  variants: {
    backgroundColor: ['responsive', 'hover', 'focus', 'disabled', 'checked'],
    borderColor: ['checked'],
    cursor: ['responsive', 'hover', 'focus', 'disabled'],
  }
}
