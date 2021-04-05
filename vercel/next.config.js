module.exports = {
    async redirects() {
      return [
        {
          source: '/',
          destination: 'https://flybis.tecwolf.com.br',
          permanent: true,
        },
      ]
    },
  }