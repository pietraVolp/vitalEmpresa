'use strict'


function criarCard (medico) {
    const card = document.createElement('div')
    const contanierMedico = document.getElementById('contanierMedico')
    contanierMedico.classList.add(
        'bg-gray-300',
        'w-1/2',
        'h-12',
        'absolute',
        'rounded-lg',
        'flex',
         'mt-32'
       
        

        
    )

    card.classList.add(
        'w-[150px]',
        'h-[73px]',
        'p-[15px]',
        'bg-zinc-950',
        'rounded-lg',
    )


    const name = document.createElement('h2')
    name.textContent = medico.name
    name.classList.add(
        'text-xl',
        'text-blue-950',
        'font-bold',
        'ml-6',
        'mt-2'
        
            
    )


    const especialidades = document.createElement('p')
    especialidades.textContent = servico.especialidades
    especialidades.classList.add(
        'text-base',
        'text-blue-950',
        'font-semibold',
        'ml-96',
        'mt-3'
           
        
    )



    card.append(titulo, preco)
    contanierServico.appendChild(card)
    card.addEventListener('click',()=> {
        console.log(servico);
        window.location.href='./info.html?id='+servico.id_servico
    })

    return card, contanierServico
        
    }


    async function preencherContainer () {
        const container = document.querySelector('body')

        const servicos = await getServicos()

        servicos.forEach(servico =>{
            const card = criarCard(servico)
            container.appendChild(card)
            console.log(card)

        })
            
        };
        preencherContainer ()
    