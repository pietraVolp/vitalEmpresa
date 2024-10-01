'use strict'

document.addEventListener('DOMContentLoaded', () => {
  // Obtém os elementos do DOM
  const nome = document.getElementById('nome')
  const email = document.getElementById('email')
  const senha = document.getElementById('senha')
  const crm = document.getElementById('crm')
  const telefone = document.getElementById('telefone')
  const dataNascimento = document.getElementById('dataNascimento')
  const especialidades = document.getElementById('especialidades')
  const cadastro = document.getElementById('cadastro')


  // Verifica se o botão foi encontrado
  if (cadastro) {
    cadastro.addEventListener('click', async () => {
      const userData = {
        nome: nome.value,
        email: email.value,
        senha: senha.value,
        crm: crm.value,
        telefone: telefone.value,
        data_nascimento: dataNascimento.value,
        especialidades: especialidades.value
       
      }

      try {
        const response = await fetch('http://localhost:8080/v1/vital/medico', {
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
          alert('Médico cadastrado com sucesso!')
          console.log(result)
          window.location.href = '/Front/html/medicos.html'
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
})
