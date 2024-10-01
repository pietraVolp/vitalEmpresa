'use strict'

const button = document.getElementById('entrar')
const senhaInput = document.getElementById('senha')


const validarLogin = async (id) => {
  const cnpj = document.getElementById('cnpj').value.trim()
  const password = document.getElementById('senha').value.trim()

  if (cnpj === '' || password === '') {
    alert('Por Favor Preencha todos os Campos !!')
  } else {
    try {
      const response = await fetch(`http://localhost:8080/v1/vital/loginEmpresa`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ cnpj, senha: password }),
    })

      const result = await response.json()

      if (response.ok) {
        if (result.status_code === 200) {
          localStorage.setItem('idC', result.id_empresa)
          window.location.href = '/Front/html/home.html'
        } else {
          alert(result.message || 'Ocorreu um erro inesperado.')
        }
      } else {
        alert(result.message || 'Ocorreu um erro ao tentar fazer login. Por favor, tente novamente.')
      }
    } catch (error) {
      console.log(error)
      alert('Ocorreu um erro ao tentar fazer login. Por favor, tente novamente.')
    }
  }
}

button.addEventListener('click', validarLogin)
