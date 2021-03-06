class TripImageController < ApplicationController
	def new
		@img = TripImage.new
	end

	# Cria uma imagem na base de dados
	def create
		@img = TripImage.new(img_params)

		if @img.save
			render :json => @img
		else
			render :json => @img.errors
		end
	end

	# Apaga uma imagem da base de dados
	def destroy
		@img = TripImage.find(params[:id])
		@img.destroy

		render :json => @img
	end

	private
	def img_params
		params.require(:trip_image).permit(:image,:trip_point_id)
	end
end
