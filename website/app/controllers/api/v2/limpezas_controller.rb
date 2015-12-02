class Api::V2::LimpezasController < ApplicationController

	before_filter :authenticate_user_from_token!, except: :getRespostas

	def submitProblemas
	    loglimpeza = LogLimpeza.new(limpeza_params)
	    loglimpeza.user_id = user.id

	    respond_to do |format|
	      if loglimpeza.save
	        render :json => '{"success" : "true"}'
	      else
	        render :json => '{"success" : "false", "error" : "problem saving limpeza"}'
	      end
	    end
  	end

  	def getRespostas
      resposta = Limpeza.find(params[:id])
      render :json => resposta
  	end

	def authenticate_user_from_token!
		user_email = params[:user_email].presence
		user = user_email && User.find_by_email(user_email)

		# Notice how we use Devise.secure_compare to compare the token
		# in the database with the token given in the params, mitigating
		# timing attacks.
		if user && Devise.secure_compare(user.authentication_token, params[:user_token])
			user = User.find_by_email(user_email)
			return true
		else
			render :json => '{"success" : "false", "error" : "authentication problem"}'
		end
	end

	private
	def limpeza_params
    	params.permit(:problema1,:problema2,:problema3 , :problema4, :problema5, :problema6, :problema7,
                                       :problema8, :problema9, :problema10, :problema11, :problema12, :problema13,
                                       :cheia_data, :cheia_origem, :cheia_perdas_monetarias, :cheia_destruicao)
  	end
end
