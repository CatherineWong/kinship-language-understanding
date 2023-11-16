# kinship-language-understanding
Modeling how humans understand language about kinship domains.
This implements human experiments and a probabilistic model based on the [From Word Models to World Models](https://arxiv.org/abs/2306.12672) paper and cognitive experiments by [Kemp and Regier](http://www.charleskemp.com/kinship/).

# Stimuli.
Stimuli for human experiments can be found [here](https://docs.google.com/spreadsheets/d/1NUBEvkUfP5HuKLurDdhnG5iayK2NglLVQWowMnPlDb4/edit#gid=0).

# Models.
The original model from Wong and Grand et. al can be found [here](https://github.com/gabegrand/world-models/tree/main/domains/d2-relational-reasoning) and runs in [Church](https://v1.probmods.org/play-space.html).

Variants of this model can be found in `models`.

# Human experiments.
Javascript code associated with the human experiment can be found in `human-experiment`. This contains JS that is likely intended to run at `cognition.run`.