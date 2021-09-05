#if !UNITY_5_4_OR_NEWER
using System;
using UnityEngine;
using UnityEngine.Serialization;
using Random = UnityEngine.Random;

namespace UiParticles
{


    /// <summary>
    /// Readble min Max Curve
    /// </summary>
    [Serializable]
    public struct UiParticleMinMaxCurve
    {

        /// <summary>
        /// Curve mode
        /// </summary>
        [FormerlySerializedAs ("CurveMode")]
        [SerializeField]
        public ParticleSystemCurveMode CurveMode;

        /// <summary>
        /// Constant used for "Constant" mode, and as a low boundry for "Random between two constnts" mode
        /// </summary>
        [FormerlySerializedAs ("MinConst")]
        [SerializeField]
        public float MinConst;

        /// <summary>
        /// MaxConst used as a top boundry for "Random between two constnts" mode
        /// </summary>
        [FormerlySerializedAs ("MaxConst")]
        [SerializeField]
        public float MaxConst;

        /// <summary>
        /// Constant used for "Curve" mode, and as a low boundry for "Random between two curves" mode
        /// </summary>
        [FormerlySerializedAs ("MinCurve")]
        [SerializeField]
        public AnimationCurve MinCurve;

        /// <summary>
        /// MaxCurve used as a top boundry for "Random between two curves" mode
        /// </summary>
        [FormerlySerializedAs ("MaxCurve")]
        [SerializeField]
        public AnimationCurve MaxCurve;


        /// <summary>
        /// Evaluate particle curve as normalized (in [0,1] range)
        /// </summary>
        /// <param name="lifetime">particle current lifetime in [0,1] range</param>
        /// <param name="randomSeed">particle random seed, for random modes</param>
        /// <returns>current MinMaxCurve value in [0, 1] range</returns>
        public float Evaluate(float lifetime, int randomSeed, float min, float max)
        {

            switch (CurveMode)
            {
                case ParticleSystemCurveMode.Constant:
                    return GetNomalized(Mathf.Clamp(MinConst, min, max), min, max);
                case ParticleSystemCurveMode.Curve:
                    return MinCurve.Evaluate(lifetime);
                case ParticleSystemCurveMode.TwoCurves:
                    Random.seed = randomSeed;
                    return Random.Range(MinCurve.Evaluate(lifetime), MaxCurve.Evaluate(lifetime));
                case ParticleSystemCurveMode.TwoConstants:
                    Random.seed = randomSeed;
                    var c0 = Mathf.Clamp(MinConst, min, max);
                    var c1 = Mathf.Clamp(MaxConst, min, max);
                    return GetNomalized(Random.Range(c0, c1), min, max);
            }
            return 0;
        }


        /// <summary>
        /// Evaluate particle curve
        /// </summary>
        /// <param name="lifetime">particle current lifetime in [0,1] range</param>
        /// <param name="randomSeed">particle random seed, for random modes</param>
        /// <returns>current MinMaxCurve value</returns>
        public float Evaluate(float lifetime, int randomSeed)
        {

            switch (CurveMode)
            {
                case ParticleSystemCurveMode.Constant:
                    return MinConst;
                case ParticleSystemCurveMode.Curve:
                    return MinCurve.Evaluate(lifetime);
                case ParticleSystemCurveMode.TwoCurves:
                    Random.seed = randomSeed;
                    return Random.Range(MinCurve.Evaluate(lifetime), MaxCurve.Evaluate(lifetime));
                case ParticleSystemCurveMode.TwoConstants:
                    Random.seed = randomSeed;
                    return Random.Range(MinConst, MaxConst);
            }
            return 0;
        }


        private float GetNomalized(float x, float min, float max)
        {
            return (x - min) / (max - min);
        }
    }
}
#endif
