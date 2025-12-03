import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Configuration State
  bool _autoCollect = true;
  double _collectionInterval = 1.0; // Seconds
  bool _autoCloseBase = true;
  double _baseTimerMinutes = 5.0;
  bool _autoLeaveOnJoin = true;
  String _generatedScript = "";

  final TextEditingController _remoteNameController = TextEditingController(text: "CollectMoneyEvent");

  void _generateScript() {
    // Logic to build the Lua script string
    StringBuffer sb = StringBuffer();
    
    sb.writeln("-- [[ BRAINROT AI CONTROLLER - GENERATED SCRIPT ]]");
    sb.writeln("-- Copy this code into your executor");
    sb.writeln("");
    sb.writeln("local Players = game:GetService('Players')");
    sb.writeln("local RunService = game:GetService('RunService')");
    sb.writeln("local LocalPlayer = Players.LocalPlayer");
    sb.writeln("");
    sb.writeln("-- CONFIGURATION");
    sb.writeln("local CONFIG = {");
    sb.writeln("    AutoCollect = ${_autoCollect.toString()},");
    sb.writeln("    CollectInterval = ${_collectionInterval.toStringAsFixed(1)},");
    sb.writeln("    AutoCloseBase = ${_autoCloseBase.toString()},");
    sb.writeln("    BaseTimerSeconds = ${(_baseTimerMinutes * 60).toInt()},");
    sb.writeln("    AutoLeaveOnJoin = ${_autoLeaveOnJoin.toString()},");
    sb.writeln("    RemoteName = '${_remoteNameController.text}' -- Verify this name with RemoteSpy");
    sb.writeln("}");
    sb.writeln("");
    sb.writeln("-- 1. MONEY COLLECTION LOOP");
    sb.writeln("spawn(function()");
    sb.writeln("    while CONFIG.AutoCollect do");
    sb.writeln("        wait(CONFIG.CollectInterval)");
    sb.writeln("        pcall(function()");
    sb.writeln("            -- Attempt to find the remote if it exists in ReplicatedStorage");
    sb.writeln("            local remote = game:GetService('ReplicatedStorage'):FindFirstChild(CONFIG.RemoteName, true)");
    sb.writeln("            if remote and remote:IsA('RemoteEvent') then");
    sb.writeln("                remote:FireServer()");
    sb.writeln("                print('[AI] Collected Money')");
    sb.writeln("            end");
    sb.writeln("        end)");
    sb.writeln("    end");
    sb.writeln("end)");
    sb.writeln("");
    sb.writeln("-- 2. BASE TIMER");
    sb.writeln("if CONFIG.AutoCloseBase then");
    sb.writeln("    spawn(function()");
    sb.writeln("        print('[AI] Base Timer Started: ' .. CONFIG.BaseTimerSeconds .. 's')");
    sb.writeln("        wait(CONFIG.BaseTimerSeconds)");
    sb.writeln("        print('[AI] Timer Expired! Closing Base...')");
    sb.writeln("        -- Add specific base closing logic here (e.g., touching a button)");
    sb.writeln("        -- Example: fireTouchInterest(game.Workspace.Base.DoorButton)");
    sb.writeln("    end)");
    sb.writeln("end");
    sb.writeln("");
    sb.writeln("-- 3. PLAYER JOIN SAFETY");
    sb.writeln("if CONFIG.AutoLeaveOnJoin then");
    sb.writeln("    Players.PlayerAdded:Connect(function(newPlayer)");
    sb.writeln("        print('[AI] ALERT: ' .. newPlayer.Name .. ' joined!')");
    sb.writeln("        LocalPlayer:Kick('[AI] Safety Protocol Triggered: Player Joined')");
    sb.writeln("    end)");
    sb.writeln("end");
    sb.writeln("");
    sb.writeln("print('[AI] SYSTEM ONLINE')");

    setState(() {
      _generatedScript = sb.toString();
    });
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _generatedScript));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Script copied to clipboard!"),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI SCRIPT GENERATOR"),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.code),
            onPressed: () {}, 
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader("CONFIGURATION"),
            const SizedBox(height: 10),
            
            // Auto Collect Settings
            _buildSwitchTile(
              "Auto Collect Money", 
              "Repeatedly fires collection events", 
              _autoCollect, 
              (v) => setState(() => _autoCollect = v)
            ),
            if (_autoCollect)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Collection Interval (seconds)", style: TextStyle(color: Colors.grey)),
                    Slider(
                      value: _collectionInterval,
                      min: 0.1,
                      max: 5.0,
                      divisions: 49,
                      label: "${_collectionInterval.toStringAsFixed(1)}s",
                      activeColor: const Color(0xFF00FF41),
                      onChanged: (v) => setState(() => _collectionInterval = v),
                    ),
                  ],
                ),
              ),

            const Divider(color: Colors.white24),

            // Base Timer Settings
            _buildSwitchTile(
              "Auto Close Base", 
              "Triggers base closure after timer", 
              _autoCloseBase, 
              (v) => setState(() => _autoCloseBase = v)
            ),
            if (_autoCloseBase)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Timer Duration (minutes)", style: TextStyle(color: Colors.grey)),
                    Slider(
                      value: _baseTimerMinutes,
                      min: 1,
                      max: 30,
                      divisions: 29,
                      label: "${_baseTimerMinutes.toInt()} min",
                      activeColor: Colors.amber,
                      onChanged: (v) => setState(() => _baseTimerMinutes = v),
                    ),
                  ],
                ),
              ),

            const Divider(color: Colors.white24),

            // Safety Settings
            _buildSwitchTile(
              "Safety Protocol", 
              "Leave server when player joins", 
              _autoLeaveOnJoin, 
              (v) => setState(() => _autoLeaveOnJoin = v)
            ),

            const SizedBox(height: 20),
            
            // Generate Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _generateScript,
                icon: const Icon(Icons.terminal),
                label: const Text("GENERATE LUA SCRIPT"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00FF41),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Output Area
            if (_generatedScript.isNotEmpty) ...[
              _buildHeader("GENERATED CODE"),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF111111),
                  border: Border.all(color: Colors.white24),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SelectableText(
                      _generatedScript,
                      style: const TextStyle(
                        fontFamily: 'Courier',
                        color: Colors.greenAccent,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: _copyToClipboard,
                        icon: const Icon(Icons.copy, size: 16),
                        label: const Text("COPY CODE"),
                        style: TextButton.styleFrom(foregroundColor: Colors.white),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF00FF41),
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      value: value,
      activeColor: const Color(0xFF00FF41),
      contentPadding: EdgeInsets.zero,
      onChanged: onChanged,
    );
  }
}
