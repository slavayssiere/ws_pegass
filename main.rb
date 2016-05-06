require './pegass.rb'

pegass = Pegass.new
pegass.connect("lavayssieres", "nvv59Js4")
pegass.displayCookies
benevoles = pegass.callUrl('/crf/rest/utilisateur?action=899&page=0&pageInfo=true&perPage=600&structure=899')

benevoles['list'].each do | benevole |
    puts benevole['nom']
end