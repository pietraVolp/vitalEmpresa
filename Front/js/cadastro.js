'use strict'

document.addEventListener('DOMContentLoaded', () => {
  // Obtém os elementos do DOM
  const nomeEmpresa = document.getElementById('nomeEmpresa')
  const nomeProprietario = document.getElementById('nomeProprietario')
  const email = document.getElementById('email')
  const senha = document.getElementById('senha')
  const cnpj = document.getElementById('cnpj')
  const telefone = document.getElementById('telefone')
  const telefoneClinica = document.getElementById('telefoneClinica')
  const cep = document.getElementById('cep')
  const logradouro = document.getElementById('logradouro')
  const bairro = document.getElementById('bairro')
  const cidade = document.getElementById('cidade')
  const estado = document.getElementById('estado')
  const cadastro = document.getElementById('cadastro')
  const cadastroEmpresa = document.getElementById('cadastroEmpresa')
 

  // Verifica se o botão foi encontrado
  if (cadastro) {
    cadastro.addEventListener('click', async () => {
      const userData = {
        nome_empresa: nomeEmpresa.value,
        nome_proprietario: nomeProprietario.value,
        email: email.value,
        senha: senha.value,
        cnpj: cnpj.value,
        telefone: telefone.value,
        telefone_clinica: telefoneClinica.value,
        cep: cep.value,
        logradouro: logradouro.value,
        bairro: bairro.value,
        cidade: cidade.value,
        estado: estado.value,
      }

      try {
        const response = await fetch('http://localhost:8080/v1/vital/empresa', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify(userData),
          redirect: 'manual'  // Evita seguir redirecionamentos automaticamente
        })

        // Verifica o código de status da resposta
        if (response.ok) {
          const result = await response.json()
          alert('Usuário cadastrado com sucesso!')
          console.log(result)
          window.location.href = '/Front/html/login.html'
        } else {
          const result = await response.json()
          alert(`Erro: ${result.message}`)
        }
      } catch (error) {
        console.error('Erro ao cadastrar usuário:', error)
        alert('Erro ao cadastrar usuário. Tente novamente.')
      }
    })
  } else {
    console.error('O botão de cadastro não foi encontrado no DOM')
  }

  window.location.href = '/Front/html/cadastro.html'
})
