'use strict'

// Aqui pegamos o elemento HTML, não o valor ainda
const cepInput = document.getElementById('cep')

async function pegarCep(cep) {
    try {
        // Formatar o CEP para remover espaços e caracteres indesejados
        cep = cep.trim().replace(/\D/g, '')  // Remove qualquer caractere que não seja dígito
        
        if (cep.length !== 8) {
            throw new Error("CEP inválido. O CEP deve ter 8 dígitos.")
        }

        const url = `https://viacep.com.br/ws/${cep}/json/`
        const response = await fetch(url)

        if (!response.ok) {
            throw new Error("Erro ao buscar o CEP. Verifique a URL ou o CEP digitado.")
        }

        const cepInfo = await response.json()

        if (cepInfo.erro) {
            throw new Error("CEP não encontrado.")
        }

        return cepInfo

    } catch (error) {
        console.error(error.message)
        alert(error.message)  // Mostra uma mensagem amigável para o usuário
        return null
    }
}

async function preencherCampos() {
    const logradouro = document.getElementById('logradouro')
    const bairro = document.getElementById('bairro')
    const localidade = document.getElementById('cidade')
    const estado = document.getElementById('estado')

    const cepInfo = await pegarCep(cepInput.value)

    if (cepInfo) {  // Se o cepInfo não for nulo
        logradouro.value = cepInfo.logradouro || ''
        bairro.value = cepInfo.bairro || ''
        localidade.value = cepInfo.localidade || ''
        estado.value = cepInfo.uf || ''
    }
}

// Adiciona o evento no input do CEP corretamente
cepInput.addEventListener('focusout', preencherCampos)
