from godot_rl.bindings.pythonic_resource import GodotRL

# 1. Point this to your Godot executable
# 2. Point 'env_path' to your project's main scene
env = GodotRL(env_path="/project.godot", convert_action_space=True)

obs = env.reset()
for i in range(10000):
    # We use random actions at first to "Fuzz" the game 
    # and find weird collision bugs
    action = env.action_space.sample()
    obs, reward, done, info = env.step(action)
    
    if done:
        obs = env.reset()

env.close()