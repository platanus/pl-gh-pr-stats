class HookService < PowerTypes::Service.new
  def subscribe(resource)
    @hook = Hook.find_by(
      resource_id: resource.id,
      resource_type: resource.class.name
    )
    if @hook
      edit_active_hook(resource, @hook, true)
    else
      create_hook(resource)
    end
  end

  def unsubscribe(resource)
    @hook = Hook.find_by(
      resource_id: resource.id,
      resource_type: resource.class.name
    )
    edit_active_hook(resource, @hook, false) if @hook
  end

  def destroy_api_hook(hook)
    resource = hook.resource
    resource.update! tracked: false if resource.tracked

    if resource.is_a?(Repository)
      destroy_api_repo_hook(resource, hook)
    elsif resource.is_a?(Organization)
      destroy_api_org_hook(resource, hook)
    end
  end

  private

  def get_hook(resource, hook)
    service = GithubService.new(user_token: resource.owner.token)
    if resource.is_a?(Repository)
      service.client.hook(
        resource.full_name, hook.gh_id
      )
    elsif resource.is_a?(Organization)
      service.client.org_hook(
        resource.login, hook.gh_id
      )
    end
  rescue Octokit::NotFound
  end

  def create_hook(resource)
    response = if resource.is_a?(Repository)
                 create_repo_hook(resource)
               elsif resource.is_a?(Organization)
                 create_org_hook(resource)
               end

    create(response, resource) if response
  end

  def create_repo_hook(repo)
    GithubService.new(user_token: repo.owner.token).client.create_hook(
      repo.full_name,
      'web',
      {
        url: "#{ENV['APPLICATION_HOST']}/github_events",
        content_type: 'json',
        secret: ENV['GH_HOOK_SECRET']
      },
      events: ['pull_request', 'pull_request_review'],
      active: true
    )
  rescue Octokit::NotFound
  end

  def create_org_hook(org)
    GithubService.new(user_token: org.owner.token).client.create_org_hook(
      org.login,
      {
        url: "#{ENV['APPLICATION_HOST']}/github_events",
        content_type: 'json',
        secret: ENV['GH_HOOK_SECRET']
      },
      events: ['repository'],
      active: true
    )
  rescue Octokit::NotFound
  end

  def edit_active_hook(resource, hook, status)
    hook.active = status
    hook.save
    if resource.is_a?(Repository)
      edit_active_repo_hook(resource, hook, status)
    elsif resource.is_a?(Organization)
      edit_active_org_hook(resource, hook, status)
    end
  end

  def edit_active_repo_hook(repo, hook, status)
    if get_hook(repo, hook).nil?
      response = create_repo_hook(repo)
      update(response, repo) if response
    end
    GithubService.new(user_token: repo.owner.token).client.edit_hook(
      repo.full_name,
      hook.reload.gh_id,
      'web',
      {
        url: "#{ENV['APPLICATION_HOST']}/github_events",
        content_type: 'json',
        secret: ENV['GH_HOOK_SECRET']
      },
      active: status
    )
  end

  def edit_active_org_hook(org, hook, status)
    if get_hook(org, hook).nil?
      response = create_org_hook(org)
      update(response, org) if response
    end
    GithubService.new(user_token: org.owner.token).client.edit_org_hook(
      org.login,
      hook.reload.gh_id,
      {
        url: "#{ENV['APPLICATION_HOST']}/github_events",
        content_type: 'json',
        secret: ENV['GH_HOOK_SECRET']
      },
      active: status
    )
  end

  def destroy_api_repo_hook(repo, hook)
    GithubService.new(user_token: repo.owner.token).client.remove_hook(
      repo.full_name,
      hook.gh_id
    )
  rescue Octokit::NotFound
  end

  def destroy_api_org_hook(org, hook)
    GithubService.new(user_token: org.owner.token).client.remove_org_hook(
      org.login,
      hook.gh_id
    )
  rescue Octokit::NotFound
  end

  def create(response, resource)
    @hook = Hook.create(
      gh_id: response[:id],
      name: response[:name],
      active: response[:active],
      ping_url: response[:ping_url],
      test_url: response[:test_url],
      resource: resource,
      hook_type: response[:type]
    )
  end

  def update(response, resource)
    @hook = Hook.update(
      gh_id: response[:id],
      name: response[:name],
      active: response[:active],
      ping_url: response[:ping_url],
      test_url: response[:test_url],
      resource: resource,
      hook_type: response[:type]
    )
  end
end
