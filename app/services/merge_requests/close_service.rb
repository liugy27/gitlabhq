module MergeRequests
  class CloseService < MergeRequests::BaseService
    def execute(merge_request, commit = nil)
      return merge_request unless can?(current_user, :update_merge_request, merge_request)

      # If we close MergeRequest we want to ignore validation
      # so we can close broken one (Ex. fork project removed)
      merge_request.allow_broken = true

      if merge_request.close
        event_service.close_mr(merge_request, current_user)
        create_note(merge_request)
        notification_service.close_mr(merge_request, current_user)
        todo_service.close_merge_request(merge_request, current_user)
        execute_hooks(merge_request, 'close')
        invalidate_cache_counts(merge_request, users: merge_request.assignees)
        merge_request.update_project_counter_caches
      end

      merge_request
    end
  end
end
