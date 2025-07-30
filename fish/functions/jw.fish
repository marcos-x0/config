function jw
    # Get workspace name from arg or prompt with gum
    if test (count $argv) -gt 0
        set workspace_name $argv[1]
    else
        set workspace_name (gum input --placeholder "Workspace name")
    end

    # Exit if no name provided
    if test -z "$workspace_name"
        gum style --foreground 196 "No workspace name provided"
        return 1
    end

    # Get repo info
    set repo_root (jj workspace root)
    set repo_name (basename $repo_root)

    # Build workspace path
    set workspace_path ~/.dev/.jj-workspaces/$repo_name/$workspace_name

    # Create workspace if it doesn't exist
    if not test -d $workspace_path
        gum spin --spinner dot --title "Creating workspace..." -- jj workspace add $workspace_path
    end

    # Create zellij tab
    zellij action new-tab --name $workspace_name --cwd $workspace_path
end
