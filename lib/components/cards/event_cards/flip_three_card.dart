import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart' as mat;
import 'package:six_seven/components/cards/card.dart';
import 'package:six_seven/components/players/cpu_player.dart';
import 'package:six_seven/components/players/overlays.dart/event_announcement_text.dart';
import 'package:six_seven/components/players/player.dart';
import 'package:six_seven/data/enums/event_cards.dart';

class FlipThreeCard extends EventActionCard {
  mat.Color announcementColor = mat.Colors.blue;
  late EventAnnouncementText flipAnnouncement;

  FlipThreeCard()
    : super(
        imagePath: "game_ui/test.png",
        descripTitleText: "Flip Three",
        descripText: "The person you select must flip 3 cards!",
      ) {
    eventEnum = EventCardEnum.FlipThree;

    // Adding to world, so 0 will be center
    flipAnnouncement = EventAnnouncementText(position: Vector2.all(0));
  }

  //No special execute on stay
  @override
  double executeOnStay(double currentValue) {
    print("This function does nothing");
    return currentValue;
  }

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();
    // await initCardIcon("game_ui/test.png");
    // initDescriptionText(
    //   description: "The person you select must flip 3 cards!",
    //   descriptionTitle: "Flip Three",
    // );
    game.world.add(flipAnnouncement);
  }

  Player _selectRandomPlayer() {
    Player? selected;
    Set<int> cantUseIndex = {};

    while (selected == null) {
      int selectIndex = Random().nextInt(game.gameManager.totalPlayerCount);
      if (cantUseIndex.contains(selectIndex)) {
        continue;
      }

      var p = game.gameManager.players[selectIndex];
      if (p.isDone) {
        cantUseIndex.add(selectIndex);
        continue;
      } else {
        selected = p;
        break;
      }
    }
    return selected;
  }

  // Heuristic is if below a certain score choose yourself, after that select highest score player
  Player _selectBasedOnHeuristic() {
    Player highestPlayer = cardUser!;
    double cutOff = 20;

    if (cardUser!.currentValue > cutOff) {
      for (var p in game.gameManager.players) {
        if (p.isDone == false && p.currentValue > highestPlayer.currentValue) {
          highestPlayer = p;
        }
      }
    }

    return highestPlayer;
  }

  // This doesn't seem to work well, tends to bust
  Player _selectBasedOnFailureProbability() {
    Player selected = cardUser!;
    double failureProb = game.gameManager.calculateFailureProbability(selected);

    for (var p in game.gameManager.players) {
      if (p != cardUser && p.isDone == false) {
        double failure = game.gameManager.calculateFailureProbability(p);
        // Favor selecting others to flip three over yourself
        if (failure >= failureProb) {
          selected = p;
        }
      }
    }

    return selected;
  }

  //Forces player to flip 3 cards
  @override
  Future<void> executeOnEvent() async {
    // Player can choose anyone
    if (cardUser!.isCpu()) {
      var cpuPlayer = cardUser as CpuPlayer;
      if (cpuPlayer.difficulty == Difficulty.easy) {
        // Makes a random selection
        affectedPlayer = _selectRandomPlayer();
        print("Flip Three Selected random player $affectedPlayer");
      } else if (cpuPlayer.difficulty == Difficulty.expert) {
        // Expert bases off of probability of busting
        affectedPlayer = _selectBasedOnHeuristic();
      } else {
        // Medium/hard functions the same way looking for highest value
        affectedPlayer = _selectBasedOnFailureProbability();
      }
    } else {
      // Player choose another player or themselves
      await choosePlayer();
    }

    // Safety check, this should realistically never happen
    if (affectedPlayer != null) {
      print("SELECTED PLAYER For FLIP THREE: $affectedPlayer");

      // Selected player has to update mandatory hits
      affectedPlayer!.mandatoryHits += 3;

      // Show chosen player as announcement
      await flipAnnouncement.setGrowingText(
        "Player ${cardUser!.playerNum} making Player ${affectedPlayer!.playerNum} flip three cards!",
        45,
        announcementColor,
        appearDurationSec: 1.3,
        showInitRemoveAnimation: false,
        holdTextForMs: 800,
        shrinkAndRemoveAtEndSec: .9,
      );
    }

    // Finish complete in handle draw
    finishEventCompleter();
  }

  @override
  void description() {
    print("${cardType.label} the person you select must flip 3 cards!");
  }
}
