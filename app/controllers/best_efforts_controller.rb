class BestEffortsController < ApplicationController
  def index
    athlete = Athlete.find_by_id_or_username(params[:id_or_username])
    if athlete.nil?
      raise ActionController::RoutingError, "Could not find athlete '#{params[:id_or_username]}' by id or username."
    else
      if params[:distance].blank?
        items = BestEffort.find_all_by_athlete_id(athlete.id)
        shaped_items = ApplicationHelper::Helper.shape_best_efforts(items)
        @best_efforts = BestEffortsDecorator.new(shaped_items)
        @best_efforts = @best_efforts.to_show_in_overview
        render json: @best_efforts
      else
        # Get best_effort_type from best_effort_type parameter.
        # 1/2 mile is passed as 1|2 mile (defined in createBestEffortsView method in athletes/bestEfforts.js)
        distance = params[:distance].tr('|', '/')
        best_effort_type = BestEffortType.find_by_name(distance)
        if best_effort_type.nil?
          raise ActionController::BadRequest, "Could not find requested best effort type '#{distance}'."
        else
          items = BestEffort.find_all_by_athlete_id_and_best_effort_type_id(athlete.id, best_effort_type.id)
          shaped_items = ApplicationHelper::Helper.shape_best_efforts(items)
          @best_efforts = BestEffortsDecorator.new(shaped_items)
          @best_efforts = @best_efforts.filter_by_type(best_effort_type.name)
          render json: @best_efforts
        end
      end
    end
  end

  def get_counts
    athlete = Athlete.find_by_id_or_username(params[:id_or_username])
    if athlete.nil?
      raise ActionController::RoutingError, "Could not find athlete '#{params[:id_or_username]}' by id or username."
    else
      results = []
      ApplicationHelper::Helper.best_effort_types.each do |best_effort_type|
        model = BestEffortType.find_by_name(best_effort_type[:name])
        if model.nil?
          next
        end
        items = BestEffort.find_all_by_athlete_id_and_best_effort_type_id(athlete.id, model.id)

        result = { :best_effort_type => best_effort_type[:name], :count => items.nil? ? 0 : items.size, :is_major => best_effort_type[:is_major] }
        results << result
      end
      render json: results
    end
  end
end