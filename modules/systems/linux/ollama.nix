{ config, pkgs, ... }:

{
  # Local LLM Engine (Ollama)
  # Hardware accelerated via NVIDIA CUDA
  services.ollama = {
    enable = true;
    package = pkgs.ollama-cuda;
    
    # Environment variables for resource management
    environmentVariables = {
      # Automatically release VRAM after 5 minutes of inactivity
      OLLAMA_KEEP_ALIVE = "5m";
    };

    # Declarative model management
    # Pulls these models on service start if missing
    loadModels = [
      "qwen2.5:7b"
      "qwen2.5-coder:7b"
      "deepseek-coder-v2:lite"
    ];
  };

  # Note: The 'ollama' binary is automatically added to systemPackages by the service.
  # Use 'ollama run <model>' for a terminal-native interaction.
}
