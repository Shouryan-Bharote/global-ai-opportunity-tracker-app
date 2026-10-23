import 'package:flutter/material.dart';

class AiInterest {
  const AiInterest({
    required this.id,
    required this.name,
    required this.category,
    required this.icon,
    required this.tags,
    required this.description,
    this.accentColor = const Color(0xFF6366F1),
  });

  final String id;
  final String name;
  final String category;
  final IconData icon;
  final List<String> tags;
  final String description;
  final Color accentColor;
}

class AiInterestCatalog {
  AiInterestCatalog._();

  static const List<String> categories = [
    'All',
    'Core Tech',
    'Competitions',
    'Applied AI',
    'Industry & Venture',
  ];

  static const List<AiInterest> allInterests = [
    AiInterest(
      id: 'gen_ai',
      name: 'Generative AI & LLMs',
      category: 'Core Tech',
      icon: Icons.auto_awesome_rounded,
      accentColor: Color(0xFF8B5CF6),
      description: 'Large language models, GPT, Claude, diffusion models & prompt tuning',
      tags: ['generative ai', 'llm', 'chatgpt', 'gpt', 'genai', 'diffusion', 'prompt', 'gemini'],
    ),
    AiInterest(
      id: 'deep_learning',
      name: 'Deep Learning & ML',
      category: 'Core Tech',
      icon: Icons.psychology_rounded,
      accentColor: Color(0xFF3B82F6),
      description: 'Neural networks, PyTorch, TensorFlow, backprop and model architectures',
      tags: ['deep learning', 'machine learning', 'neural', 'pytorch', 'tensorflow', 'ai', 'data science'],
    ),
    AiInterest(
      id: 'hackathons',
      name: 'AI Hackathons',
      category: 'Competitions',
      icon: Icons.emoji_events_rounded,
      accentColor: Color(0xFFF59E0B),
      description: 'Competitive coding, prototype jams, prize bounties and team building',
      tags: ['hackathon', 'competition', 'challenge', 'prize', 'kaggle', 'bounty', 'builder'],
    ),
    AiInterest(
      id: 'agents',
      name: 'Autonomous Agents',
      category: 'Applied AI',
      icon: Icons.smart_toy_rounded,
      accentColor: Color(0xFF10B981),
      description: 'Multi-agent workflows, tool use, LangChain, CrewAI & AutoGen',
      tags: ['agent', 'autonomous', 'crewai', 'langchain', 'autogen', 'agents', 'workflow'],
    ),
    AiInterest(
      id: 'computer_vision',
      name: 'Computer Vision',
      category: 'Core Tech',
      icon: Icons.remove_red_eye_rounded,
      accentColor: Color(0xFFEC4899),
      description: 'Image synthesis, object tracking, YOLO, NeRFs & visual perception',
      tags: ['computer vision', 'vision', 'opencv', 'object detection', 'yolo', 'image', 'video'],
    ),
    AiInterest(
      id: 'nlp',
      name: 'Natural Language (NLP)',
      category: 'Core Tech',
      icon: Icons.record_voice_over_rounded,
      accentColor: Color(0xFF06B6D4),
      description: 'Text analysis, speech-to-text, translation, tokens & semantics',
      tags: ['nlp', 'natural language', 'transformer', 'speech', 'voice', 'audio', 'linguistics'],
    ),
    AiInterest(
      id: 'startups',
      name: 'AI Startups & Pitching',
      category: 'Industry & Venture',
      icon: Icons.rocket_launch_rounded,
      accentColor: Color(0xFFEF4444),
      description: 'Early-stage founders, demo days, investor connections and scale',
      tags: ['startup', 'pitch', 'demo day', 'investor', 'venture', 'founder', 'business'],
    ),
    AiInterest(
      id: 'mlops',
      name: 'MLOps & Infrastructure',
      category: 'Applied AI',
      icon: Icons.cloud_sync_rounded,
      description: 'Model deployment, Kubernetes, GPU orchestration and observability',
      tags: ['mlops', 'infrastructure', 'cloud', 'kubernetes', 'deployment', 'scalability', 'docker'],
    ),
    AiInterest(
      id: 'robotics',
      name: 'Robotics & Embodied AI',
      category: 'Applied AI',
      icon: Icons.precision_manufacturing_rounded,
      accentColor: Color(0xFF14B8A6),
      description: 'Hardware, ROS, autonomous drones, kinematics & spatial AI',
      tags: ['robotics', 'robot', 'ros', 'embodied', 'edge ai', 'hardware', 'drones'],
    ),
    AiInterest(
      id: 'safety',
      name: 'AI Safety & Ethics',
      category: 'Industry & Venture',
      icon: Icons.shield_rounded,
      accentColor: Color(0xFF64748B),
      description: 'Model alignment, red-teaming, bias mitigation and compliance',
      tags: ['safety', 'ethics', 'alignment', 'governance', 'policy', 'red teaming', 'trust'],
    ),
    AiInterest(
      id: 'healthcare',
      name: 'AI in Healthcare & Bio',
      category: 'Industry & Venture',
      icon: Icons.biotech_rounded,
      accentColor: Color(0xFFE11D48),
      description: 'Drug discovery, clinical intelligence, genomics and radiology',
      tags: ['healthcare', 'bio', 'biotech', 'medicine', 'health', 'pharma', 'clinical'],
    ),
    AiInterest(
      id: 'fintech',
      name: 'Fintech & Quantitative AI',
      category: 'Industry & Venture',
      icon: Icons.account_balance_rounded,
      accentColor: Color(0xFF0D9488),
      description: 'Algorithmic trading, fraud defense, risk scoring and Web3 AI',
      tags: ['fintech', 'finance', 'trading', 'crypto', 'quantitative', 'banking', 'defi'],
    ),
  ];

  static List<String> get defaultSelectedNames => [
    'Generative AI & LLMs',
    'AI Hackathons',
    'Deep Learning & ML',
  ];

  static AiInterest? findByName(String name) {
    for (final interest in allInterests) {
      if (interest.name.toLowerCase() == name.toLowerCase() ||
          interest.id.toLowerCase() == name.toLowerCase()) {
        return interest;
      }
    }
    return null;
  }

  static bool eventMatchesInterests(List<String> eventTags, List<String> userInterests) {
    if (userInterests.isEmpty || eventTags.isEmpty) return false;
    final lowerEventTags = eventTags.map((e) => e.toLowerCase()).toList();

    for (final userInterest in userInterests) {
      final interestObj = findByName(userInterest);
      if (interestObj != null) {
        for (final tag in interestObj.tags) {
          if (lowerEventTags.any((e) => e.contains(tag) || tag.contains(e))) {
            return true;
          }
        }
      } else {
        // Fallback exact/substring match
        final lower = userInterest.toLowerCase();
        if (lowerEventTags.any((e) => e.contains(lower) || lower.contains(e))) {
          return true;
        }
      }
    }
    return false;
  }
}
