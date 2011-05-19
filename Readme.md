# Stacked Recommenders

## Adaptive User Model Aggregation Through Individual Accuracy Estimation

In the field of artificial intelligence,
*recommender systems* are user modeling methods,
that can predict the relevance of an item to a user.
These powerful systems can use multiple aspects of known data
to estimate what each user of a system will think of each available item.

Modern recommender systems blend multiple standard recommenders
in order to leverage disjoint patterns in the available data.
By combining different types of recommenders,
complex predictions that rely on much evidence can be made.

However, we posit these systems have an important weakness.
There exists an underlying, misplaced subjectivity to relevance prediction.
Each chosen recommender system reflects how the system
generally thinks each user and item should be modeled.

This paper presents a novel method for adaptive prediction aggregation,
called *stacked recommenders*.
Multiple recommender systems are combined on a per-user and per-item basis
by estimating how accurate each recommender will be for the current user and item.
This is done by creating a set of secondary error estimating recommenders.
By estimating predictions and their accuracy based 
on the current user and item,
optimally adaptive predictions can be estimated.

Prediction aggreation is tested in a recommendations scenario,
and rank aggregation in a personalized search scenario.
Our initial results are promising, showing that stacked recommenders
can outperform both standard recommenders and simple aggregation methods.

The paper can be found in the "thesis/dist" folder, 
and the corresponding implementation in the "code" folder.


## Colophon

This is a Master Thesis in the field of Artificial Intelligence,
as part of my degree in Computer Science
at the Norwegian University of Science and Technology (NTNU).

My specialization is in the field of intelligent systems, 
at the Department of Computer and Information Science (IDI), 
faculty of Information Technology, Mathematics and Electrical Engineering (IME).


