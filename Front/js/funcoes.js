export async function postEmpresa (empresa) {
    const url = 'http://localhost:8080/v1/vital/empresa'
    const options = {
       method: 'POST',
       headers: {
          'Content-Type': 'application/json'
       },
       body: JSON.stringify (cliente)
    }
    const response = await fetch (url, options)
 
    return response.ok
 }




