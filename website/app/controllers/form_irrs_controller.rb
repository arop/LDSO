class FormIrrsController < ApplicationController
	before_filter :custom_auth!, :except => [:info]

	# Verifica permissões do utilizador, apenas utilizador com permissões > 1 é que pode
	# aceder aos form irrs
	def custom_auth!
		if authenticate_user!
			@permissoes = current_user.permissoes
			if current_user.permissoes > 1
				return true
			else
				render 'common/noaccess'
			end
		else
			render 'common/noaccess'
		end
	end

	# Faz render da pagina de informações dum form irr
	def info
		render 'info'
	end

	# Faz render da pagina dos formulários do utilizador
	def index
		@all = false
		@form_irrs = current_user.form_irrs.paginate(:page => params[:page], :per_page => 10).order('updated_at DESC')
	end

	# Faz render da página de criação de formulário
	def new
		@form_irr = FormIrr.new
		@is_show = ''
		@is_edit = false
	end

	# Faz render de todos os form irrs (apenas para permissão > 4)
	def all
		if current_user.permissoes > 4
			@form_irrs = FormIrr.all.paginate(:page => params[:page], :per_page => 10).order('updated_at DESC')
			@all = true
			render 'index'
		else
			render 'common/noaccess'
		end
	end

	# Faz render de um form irr preenchido
	def show
		@form_irr = FormIrr.find(params[:id])
		@images = @form_irr.form_irr_images

		if @form_irr.user_id != current_user.id && @permissoes < 4
			render 'common/noaccess'
		else
			@is_show = 'form-disabled'
			@is_edit = false
		end
	end

	# Faz render dum formulário irr já preenchido para editar
	def edit
		@form_irr = FormIrr.find(params[:id])
		@images = @form_irr.form_irr_images

		if @form_irr.user_id != current_user.id && @permissoes < 4
			render 'common/noaccess'
		else
			@is_show = ''
			@is_edit = true
		end
	end

	# Cria na base de dados um form irr, com o utilizador que esteja autenticado
	# O form irr começa não validado
	# Guarda e cria as imagens (se existentes) na base de dados
	def create
		@form_irr = FormIrr.new(form_irr_params)
		@form_irr.user_id = current_user.id
		@form_irr.edit_user_id = current_user.id
		@form_irr.validated = false

		if @form_irr.save
			if params[:images]
				params[:images].each { |image|
					FormIrrImage.create(image: image, form_irr_id: @form_irr.id)
				}
			end
			UserMailer.irr_email(@form_irr).deliver_now
			redirect_to @form_irr
		else
			render 'new'
		end
	end

	# Faz update dum form irr na base de dados, atualizando o "edit_user_id" (utilizador que esta
	# autenticado) guardando assim o id do utilizador que editou o form
	# Acrescenta novas imagens (se existentes)
	def update
		@form_irr = FormIrr.find(params[:id])
		@form_irr.edit_user_id = current_user.id

		if @form_irr.update(form_irr_params)
			if params[:images]
				params[:images].each { |image|
					FormIrrImage.create(image: image, form_irr_id: @form_irr.id)
				}
			end

			redirect_to @form_irr
		else
			render 'edit'
		end
	end

	# Faz render dos formulários não validados (apenas para permissoes > 4, ou para permissoes > 2 e do mesmo
	# concelho)
	def validate_index
		if current_user.permissoes > 4 #admin e tecnico do engenho e rio
			@form_irrs = FormIrr.where(:validated => false).paginate(:page => params[:page], :per_page => 10).order('updated_at')
			render 'index_not_validated'
		elsif current_user.permissoes > 2 #tecnico multimunicipio e apenas do mesmo concelho
			concelho = current_user.concelho_id

			@form_irrs = FormIrr.joins(:user).select('form_irrs.*, users.concelho_id')
					             .where(:validated => false, users: {concelho_id: concelho})
					             .paginate(:page => params[:page], :per_page => 10).order('updated_at')
			render 'index_not_validated'
		else
			render 'common/noaccess'
		end
	end

	# Valida o form irr (apenas para admin [permissoes > 5]), guardando na base de dados
	def validate
		if current_user.permissoes > 5
			form_irr = FormIrr.find(params[:id])
			if form_irr.update_column(:validated, true)
				redirect_to :back
			end
		else
			render 'common/noaccess'
		end
	end

	# Apaga o form irr da base de dados (apagando todos os dados relacionados com o mesmo)
	def destroy
		@form_irr = FormIrr.find(params[:id])
		@form_irr.destroy

		redirect_to form_irrs_path
	end

	def retrieveImage
		render '_imagem_help'
	end

	private
	# Parametros permitidos para o form irr
	def form_irr_params
		params.require(:form_irr).permit(:idRio,:nomeRio,:lat,:lon,:margem,:tipoDeVale,:perfilDeMargens,:larguraDaSuperficieDaAgua,:profundidadeMedia,:seccao,:velocidadeMedia,:caudal,:substratoDasMargens_soloArgiloso,:substratoDasMargens_arenoso,:substratoDasMargens_pedregoso,:substratoDasMargens_rochoso,
			:substratoDasMargens_artificialPedra,:substratoDasMargens_artificialBetao,:substratoDoLeito_blocoseRocha,:substratoDoLeito_calhaus,:substratoDoLeito_cascalho,:substratoDoLeito_areia,:substratoDoLeito_limo,:substratoDoLeito_solo,:substratoDoLeito_artificial,:substratoDoLeito_naoEVisivel,:estadoGeraldaLinhadeAgua,
			:erosao_semErosao,:erosao_formacaomais3,:erosao_formacao1a3,:erosao_quedamuros,:erosao_rombos,:sedimentacao_ausente,:sedimentacao_decomposicao,:sedimentacao_mouchoes,:sedimentacao_ilhassemveg,:sedimentacao_ilhascomveg,:sedimentacao_deposicaosemveg,:sedimentacao_deposicaocomveg,:sedimentacao_rochas,
			:pH,:condutividade,:temperatura,:nivelDeOxigenio,:percentagemDeOxigenio,:nitratos,:nitritos,:transparencia,:oleo,:espuma,:esgotos,:impurezas,:sacosDePlastico,:latas,:indiciosNaAgua_outros,:corDaAgua,:odorDaAgua,:planarias,:hirudineos,
			:oligoquetas,:simulideos,:quironomideos,:ancilideo,:limnideo,:bivalves,:patasNadadoras,:pataLocomotoras,:trichopteroS,:trichopteroC,:odonata,:heteropteros,:plecopteros,:baetideo,:cabecaPlanar,:crustaceos,:acaros,:pulgaDeAgua,:insetos,:megalopteres,:intervencoes_edificios ,
			:intervencoes_pontes,:intervencoes_limpezasDasMargens,:intervencoes_estabilizacaoDeMargens,:intervencoes_modelacaoDeMargensNatural,:intervencoes_modelacaoDeMargensArtificial,:intervencoes_barragem,:intervencoes_diques,:intervencoes_rioCanalizado,:intervencoes_rioEntubado,
			:intervencoes_esporoes ,:intervencoes_paredoes,:intervencoes_tecnicasDeEngenhariaNatural,:intervencoes_outras,:ocupacao_florestaNatural,:ocupacao_florestaPlantadas,:ocupacao_matoAlto,:ocupacao_matoRasteiro,:ocupacao_pastagem,:ocupacao_agricultura,:ocupacao_espacoAbandonado,
			:ocupacao_jardins,:ocupacao_zonaEdificada,:ocupacao_zonaIndustrial,:ocupacao_ruas,:ocupacao_entulho,:patrimonio_moinho,:patrimonio_acude,:patrimonio_microAcude1,:patrimonio_microAcude2,:patrimonio_barragem,:patrimonio_levadas,:patrimonio_pesqueiras,:patrimonio_escadasDePeixe,
			:patrimonio_poldras,:patrimonio_pontesSemPilar,:patrimonio_pontesComPilar,:patrimonio_passagemAVau,:patrimonio_barcos,:patrimonio_cais,:patrimonio_igreja,:patrimonio_solares,:patrimonio_nucleoHabitacional,:patrimonio_edificiosParticulares,:patrimonio_edificiosPublicos,
			:patrimonio_ETA,:patrimonio_descarregadoresDeAguasPluviais,:patrimonio_coletoresSaneamento,:patrimonio_defletoresArtificiais,:patrimonio_motaLateral,:poluicao_descargasDomesticas,:poluicao_descargasETAR,:poluicao_descargasIndustriais,:poluicao_descargasQuimicas,
			:poluicao_descargasAguasPluviais,:poluicao_presencaCriacaoAnimais,:poluicao_lixeiras,:poluicao_lixoDomestico,:poluicao_entulho,:poluicao_monstrosDomesticos,:poluicao_sacosDePlastico,:poluicao_latasMaterialFerroso,:poluicao_queimadas,:salamandraLusitanica,:salamandraPintasAmarelas,
			:tritaoVentreLaranja,:raIberica,:raVerde,:sapoComum,:lagartoDeAgua,:cobraAguaDeColar,:cagado,:repteis_outro,:guardaRios,:garcaReal,:melroDeAgua,:galinhaDeAgua,:patoReal,:tentilhaoComum,:chapimReal,:aves_outro,:lontras,:morcegosDeAgua,:toupeiraDaAgua,:ratoDeAgua,:ouricoCacheiro,
			:armilho,:mamiferos_outro,:enguia,:lampreia,:salmao,:truta,:bogaPortuguesa,:bogaDoNorte,:peixes_outro,:percaSol,:tartarugaDaFlorida,:caranguejoPeludoChines,:gambusia,:mustelaVison,:lagostimVermelho,:trutaArcoIris,:achiga,:fauna_outro,:salgueiral,:amial,:freixal,:choupal,:ulmeiral,
			:sanguinos,:ladual,:tramazeiras,:carvalhal,:sobreiral,:azinhal,:flora_outro,:conservacaoBosqueRibeirinho,:silvas,:ervaDaFortuna,:plumas,:lentilhaDaAgua,:pinheirinha,:jacintoDeAgua,:vegetacaoInvasora_outro,:obstrucaoDoLeitoMargens,:disponibilizacaoDeInformacao,:envolvimentoPublico,
			:acao,:legislacao,:estrategia,:gestaoDasIntervencoes, :irr_hidrogeomorfologia,:irr_qualidadedaagua,:irr_alteracoesantropicas, :irr_corredorecologico, :irr_participacaopublica,:irr_organizacaoeplaneamento,:validated, :irr)
	end
end
