import 'dart:async';
import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // AI State
  bool _isAiActive = false;
  bool _isBaseOpen = true;
  bool _isInBase = true;
  int _moneyCollected = 0;
  
  // Timers
  Timer? _collectionTimer;
  Timer? _baseTimer;
  int _baseTimerSeconds = 60; // Default 60 seconds before closing base
  int _currentTimerSeconds = 60;

  // Logs
  final List<String> _logs = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _stopAllActions();
    _scrollController.dispose();
    super.dispose();
  }

  void _addLog(String message) {
    setState(() {
      _logs.add("[${DateTime.now().toIso8601String().substring(11, 19)}] $message");
    });
    // Auto-scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _startAi() {
    if (_isAiActive) return;

    setState(() {
      _isAiActive = true;
      _isBaseOpen = true;
      _isInBase = true;
      _currentTimerSeconds = _baseTimerSeconds;
    });

    _addLog("AI STARTED. Initializing sequence...");
    _addLog("Status: In Base, Base Open.");

    // Start Money Collection Loop
    _collectionTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _collectMoney();
    });

    // Start Base Timer Countdown
    _baseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_currentTimerSeconds > 0) {
          _currentTimerSeconds--;
        } else {
          _handleTimerExpiry();
        }
      });
    });
  }

  void _stopAllActions() {
    _collectionTimer?.cancel();
    _baseTimer?.cancel();
    setState(() {
      _isAiActive = false;
    });
    _addLog("AI STOPPED. All actions halted.");
  }

  void _collectMoney() {
    if (!_isInBase) return; // Can't collect if not in base (assumption)
    
    // Simulate collecting random amount
    int amount = 100 + (DateTime.now().millisecond % 50); 
    setState(() {
      _moneyCollected += amount;
    });
    _addLog("Collected \$$amount from Brainrot.");
  }

  void _handleTimerExpiry() {
    _baseTimer?.cancel();
    _closeBase();
  }

  void _closeBase() {
    if (!_isBaseOpen) return;
    setState(() {
      _isBaseOpen = false;
    });
    _addLog("TIMER EXPIRED. Closing Base to secure loot.");
  }

  void _leaveBase() {
    if (!_isInBase) return;
    setState(() {
      _isInBase = false;
    });
    _addLog("Leaving Base immediately.");
  }

  // Simulation Triggers
  void _simulatePlayerJoin() {
    _addLog("ALERT: New Player Joined Server!");
    
    if (_isInBase) {
      _leaveBase();
    }
    
    _stopAllActions();
    _addLog("SAFETY PROTOCOL: Disconnected to avoid detection.");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("STEAL A BRAINROT // AI CONTROL"),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _stopAllActions();
              setState(() {
                _moneyCollected = 0;
                _logs.clear();
                _isBaseOpen = true;
                _isInBase = true;
                _currentTimerSeconds = _baseTimerSeconds;
              });
              _addLog("System Reset.");
            },
          )
        ],
      ),
      body: Column(
        children: [
          // Status Dashboard
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.black54,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatusCard("STATUS", _isAiActive ? "RUNNING" : "IDLE", _isAiActive ? Colors.green : Colors.grey),
                _buildStatusCard("MONEY", "\$$_moneyCollected", Colors.amber),
                _buildStatusCard("TIMER", "${_currentTimerSeconds}s", _currentTimerSeconds < 10 ? Colors.red : Colors.blue),
              ],
            ),
          ),
          
          const Divider(height: 1, color: Colors.white24),

          // Detailed State
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(child: _buildStateIndicator("Base Status", _isBaseOpen ? "OPEN" : "CLOSED", _isBaseOpen ? Colors.green : Colors.red)),
                const SizedBox(width: 10),
                Expanded(child: _buildStateIndicator("Location", _isInBase ? "IN BASE" : "LEFT BASE", _isInBase ? Colors.blue : Colors.orange)),
              ],
            ),
          ),

          // Logs Area
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(8),
                itemCount: _logs.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      _logs[index],
                      style: const TextStyle(
                        fontFamily: 'Courier',
                        fontSize: 12,
                        color: Colors.greenAccent,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Controls
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isAiActive ? null : _startAi,
                        icon: const Icon(Icons.play_arrow),
                        label: const Text("START AI"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.withOpacity(0.2),
                          foregroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: !_isAiActive ? null : _stopAllActions,
                        icon: const Icon(Icons.stop),
                        label: const Text("STOP AI"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.withOpacity(0.2),
                          foregroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text("SIMULATION TRIGGERS", style: TextStyle(color: Colors.grey, fontSize: 10)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _simulatePlayerJoin,
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.orange),
                        child: const Text("SIMULATE PLAYER JOIN"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Courier',
          ),
        ),
      ],
    );
  }

  Widget _buildStateIndicator(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: color.withOpacity(0.8), fontSize: 10)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
